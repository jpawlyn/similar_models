class Post < ActiveRecord::Base
  has_many :author_posts
  has_many :authors, through: :author_posts
  has_and_belongs_to_many :tags

  has_similar_models :authors
  has_similar_models :tags, as: :similar_posts_by_tag
  has_similar_models :authors, :tags, as: :similar_posts_by_author_and_tag
end

class Tag < ActiveRecord::Base
end

class Author < ActiveRecord::Base
end

class AuthorPost < ActiveRecord::Base
  belongs_to :author
  belongs_to :post
end
