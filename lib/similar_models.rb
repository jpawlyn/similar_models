require 'similar_models/version'

module SimilarModels

  def has_similar_models(*many_to_many_associations, as: nil)
    as = "similar_#{model_name.plural}" unless as

    # defaults to 'def similar_{model name}'
    define_method as do
      table_name = self.class.table_name
      primary_key = self.class.primary_key
      primary_key_ref = "#{table_name}.#{primary_key}"
      association_scopes = []

      many_to_many_associations.each do |many_to_many_association|
        assocation = self.class.reflect_on_association(many_to_many_association)
        join_table, foreign_key, association_foreign_key = self.class.join_table_values(assocation)

        association_scopes << self.class.where(
          "#{join_table}.#{association_foreign_key} IN \
          (select #{join_table}.#{association_foreign_key} from #{join_table} \
          where #{join_table}.#{foreign_key} = :foreign_key)", foreign_key: self.id
        ).joins("INNER JOIN #{join_table} ON #{join_table}.#{foreign_key} = #{primary_key_ref}")
      end

      scope = self.class.select("#{table_name}.*, count(#{primary_key_ref}) AS #{as}_model_count").
        where.not(primary_key => self.id).order("#{as}_model_count DESC")
      group_by_clause = self.class.column_names.map { |column| "#{table_name}.#{column}"}.join(', ')

      # if there is only one many-to-many association no need to use UNION sql syntax
      if association_scopes.one?
        scope.merge(association_scopes.first).group(group_by_clause)
      else
        # see http://blog.ubersense.com/2013/09/27/tech-talk-unioning-scoped-queries-in-rails/
        scope.from("((#{association_scopes.map(&:to_sql).join(') UNION ALL (')})) AS #{table_name}").group(group_by_clause)
      end
    end

    def self.join_table_values(many_to_many_assocation)
      if many_to_many_assocation.macro == :has_and_belongs_to_many
        join_table = many_to_many_assocation.join_table
        foreign_key = many_to_many_assocation.foreign_key
        association_foreign_key = many_to_many_assocation.association_foreign_key
      elsif many_to_many_assocation.macro == :has_many
        join_table = many_to_many_assocation.through_reflection.table_name
        foreign_key = many_to_many_assocation.through_reflection.foreign_key
        association_foreign_key = many_to_many_assocation.foreign_key
      end
      [join_table, foreign_key, association_foreign_key]
    end
  end
end

# Extend ActiveRecord functionality
ActiveRecord::Base.extend SimilarModels
