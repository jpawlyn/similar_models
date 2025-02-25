require 'similar_models/version'

module SimilarModels

  def has_similar_models(*many_to_many_associations, as: nil)
    as ||= "similar_#{model_name.plural}"

    # example sql query for one many to many association:
    #
    # SELECT posts.*,
    #   (select count(*) from author_posts where post_id != posts.alt_id and author_id in
    #     (select author_id from author_posts where post_id = posts.alt_id)) AS similar_posts_commonality_count
    #   FROM "posts"
    #   ORDER BY similar_posts_commonality_count DESC, created_at DESC
    #
    define_singleton_method as do
      primary_key_ref = "#{table_name}.#{primary_key}"
      similarity_counts = []

      many_to_many_associations.each do |many_to_many_association|
        association = reflect_on_association(many_to_many_association)
        join_table, foreign_key, association_foreign_key = join_table_values(association)

        similarity_counts <<
          "(select count(*) from #{join_table} where #{foreign_key} != #{primary_key_ref} and " \
          "#{association_foreign_key} in " \
          "(select #{association_foreign_key} from #{join_table} where #{foreign_key} = #{primary_key_ref}))"
      end

      order_clause = "#{as}_commonality_count DESC"
      order_clause += ", created_at DESC" if column_names.include?('created_at')
      select("#{table_name}.*, #{similarity_counts.join(' + ')} AS #{as}_commonality_count").order(order_clause)
    end

    # example sql query for one many to many association:
    #
    # SELECT posts.*, count(posts.alt_id) AS similar_posts_commonality_count
    #   FROM "posts"
    #   INNER JOIN author_posts ON author_posts.post_id = posts.alt_id
    #     WHERE "posts"."alt_id" != ? AND
    #       author_posts.author_id IN (select author_posts.author_id from author_posts where author_posts.post_id = ?)
    #   GROUP BY posts.alt_id, posts.created_at, posts.updated_at
    #   ORDER BY similar_posts_commonality_count DESC, created_at DESC
    #
    define_method as do
      table_name = self.class.table_name
      primary_key = self.class.primary_key
      primary_key_ref = "#{table_name}.#{primary_key}"
      association_scopes = []

      many_to_many_associations.each do |many_to_many_association|
        association = self.class.reflect_on_association(many_to_many_association)
        join_table, foreign_key, association_foreign_key = self.class.join_table_values(association)

        association_scopes << self.class.where(
          "#{join_table}.#{association_foreign_key} IN \
          (select #{join_table}.#{association_foreign_key} from #{join_table} \
          where #{join_table}.#{foreign_key} = :foreign_key)", foreign_key: self.id
        ).joins("INNER JOIN #{join_table} ON #{join_table}.#{foreign_key} = #{primary_key_ref}")
      end

      order_clause = "#{as}_commonality_count DESC"
      order_clause += ", created_at DESC" if self.class.column_names.include?('created_at')
      scope = self.class.select("#{table_name}.*, count(#{primary_key_ref}) AS #{as}_commonality_count").
        where.not(primary_key => self.id).order(order_clause)
      group_by_clause = self.class.column_names.map { |column| "#{table_name}.#{column}"}.join(', ')

      # if there is only one many-to-many association no need to use UNION sql syntax
      if association_scopes.one?
        scope.merge(association_scopes.first).group(group_by_clause)
      else
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
