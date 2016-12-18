require "most_related/version"

module MostRelated

  # `most_related` returns those models that have the most
  #  associated models in common
  #
  # Post example:
  #
  #   class Post < ActiveRecord::Base
  #     has_most_related :authors
  #     has_most_related :tags, as: :most_related_by_tags
  #     has_most_related :authors, :tags, as: :most_related_by_author_or_tag
  #
  #     has_and_belongs_to_many :tags
  #     has_many :author_posts
  #     has_many :authors, through: :author_posts
  #   end
  #
  #   class Tag < ActiveRecord::Base
  #   end
  #
  #   class Author < ActiveRecord::Base
  #     has_many :author_posts
  #   end
  #
  #   class AuthorPosts < ActiveRecord::Base
  #     belongs_to :author
  #     belongs_to :post
  #   end
  #
  # To return the posts with the most authors in common with `post`, in descending order:
  #   post.most_related
  #
  # To return the posts with the most tags in common with `post`, in descending order:
  #   post.most_related_by_tag
  #
  # To return the posts with the most authors and tags in common with `post`, in descending order:
  #   post.most_related_by_author_or_tag
  #
  # The count of the associated models in common is accessible on each returned model
  #   eg post.most_related_count, post.most_related_by_tag_count and post.most_related_by_author_or_tag_count
  #
  def has_most_related(*many_to_many_associations, as: :most_related)

    # defaults to 'def most_related'
    define_method as do
      table_name = self.class.table_name
      association_scopes = []

      many_to_many_associations.each do |many_to_many_association|
        assocation = self.class.reflect_on_association(many_to_many_association)
        join_table, foreign_key, association_foreign_key = self.class.join_table_values(assocation)

        association_scopes << self.class.where("#{join_table}.#{association_foreign_key} IN " +
          "(select #{join_table}.#{association_foreign_key} from #{join_table} " +
          "where #{join_table}.#{foreign_key} = :foreign_key)", foreign_key: self.id).
          joins("INNER JOIN #{join_table} ON #{join_table}.#{foreign_key} = #{table_name}.id")
      end

      scope = self.class.select("#{table_name}.*, count(#{table_name}.id) AS #{as}_count").
        where.not(id: self.id).order("#{as}_count DESC")
      group_by_clause = 'id'

      # if there is only one many-to-many association no need to use UNION sql syntax
      if association_scopes.one?
        scope.merge(association_scopes.first).group(group_by_clause)
      else
        # with postgres the group by clause has to be different
        # http://dba.stackexchange.com/questions/88988/postgres-error-column-must-appear-in-the-group-by-clause-or-be-used-in-an-aggre
        if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
          group_by_clause = self.class.column_names.join(', ')
        end

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
ActiveRecord::Base.extend MostRelated
