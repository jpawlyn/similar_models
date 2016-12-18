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
  #     has_most_related [:authors, :tags], as: :most_related_by_author_or_tag
  #
  #     has_many :author_posts
  #     has_many :authors, through: :author_posts
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
  def has_most_related(many_to_many_associations, as: :most_related)

    # defaults to 'def most_related'
    define_method as do
      table_name = self.class.table_name
      association_scopes = []

      many_to_many_associations = if many_to_many_associations.is_a?(Array)
        many_to_many_associations
      else
        [many_to_many_associations]
      end

      many_to_many_associations.each do |many_to_many_association|
        assocation = self.class.reflect_on_association(many_to_many_association)
        join_table, foreign_key, association_foreign_key = self.class.join_table_values(assocation)

        association_scopes << self.class.where("#{join_table}.#{association_foreign_key} IN " +
          "(select #{join_table}.#{association_foreign_key} from #{join_table} " +
          "where #{join_table}.#{foreign_key} = :foreign_key)", foreign_key: self.id).
          joins("INNER JOIN #{join_table} ON #{join_table}.#{foreign_key} = #{table_name}.id")
      end

      # with postgres, multiple many-to-many associations doesn't work and here's why
      # http://dba.stackexchange.com/questions/88988/postgres-error-column-must-appear-in-the-group-by-clause-or-be-used-in-an-aggre
      scope = self.class.select("#{table_name}.*, count(#{table_name}.id) AS #{as}_count").
        where.not(id: self.id).group("#{table_name}.id").order("#{as}_count DESC")

      # if there is only one many-to-many association no need to use UNION sql syntax
      if association_scopes.size == 1
        scope.merge(association_scopes.first)
      else
        # see http://blog.ubersense.com/2013/09/27/tech-talk-unioning-scoped-queries-in-rails/
        scope.from("((#{association_scopes.map(&:to_sql).join(') UNION ALL (')})) AS #{table_name}")
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
