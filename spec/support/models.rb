class Post < ActiveRecord::Base
  has_most_related :authors
  has_most_related :tags, as: :most_related_by_tag
  has_most_related :authors, :tags, as: :most_related_by_author_or_tag

  has_and_belongs_to_many :tags
  has_many :author_posts
  has_many :authors, through: :author_posts
end

class Tag < ActiveRecord::Base
end

class Author < ActiveRecord::Base
end

class AuthorPost < ActiveRecord::Base
  belongs_to :author
  belongs_to :post
end
