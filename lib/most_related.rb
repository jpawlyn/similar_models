require "most_related/version"

module MostRelated

  # most_related returns those models that have the most
  # specified many to many associations in common
  #
  # Post example:
  #
  #   class Post < ActiveRecord::Base
  #     has_most_related :authors
  #     has_most_related :tags, as: :most_related_by_tags
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
  #   To return the posts with the most authors in common with post, in descending order:
  #   post.most_related
  #
  #   To return the posts with the most tags in common with post, in descending order:
  #   post.most_related_by_tags
  #
  def has_most_related(many_to_many_association, as: :most_related)

    # defaults to 'def most_related'
    define_method as do
      table_name = self.class.table_name
      many_to_many_assocation = self.class.reflect_on_association(many_to_many_association)
      join_table, foreign_key, association_foreign_key = self.class.join_table_values(many_to_many_assocation)

      self.class.select("#{table_name}.*, count(#{table_name}.id) AS common_count").
        where("#{join_table}.#{association_foreign_key} IN " +
          "(select #{join_table}.#{association_foreign_key} from #{join_table} where #{join_table}.#{foreign_key} = :foreign_key)",
          foreign_key: self.id).
        where.not(id: self.id).
        joins("INNER JOIN #{join_table} ON #{join_table}.#{foreign_key} = #{table_name}.id").
        group("#{table_name}.id").
        order('common_count DESC')
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