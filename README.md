# Similar Models

Adds a `similar_{model name plural}` method to an active record model, but can be set to any name using `as: {method name}`. It returns the most similar models of the same class based on associated models in common.

The association(s) have to be many to many, so either habtm or 'has_many though'.

## Installation

Add this line to your application's Gemfile:

    gem 'similar_models'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install similar_models

## Usage

Post example

    class Post < ActiveRecord::Base
      has_many :author_posts
      has_many :authors, through: :author_posts
      has_and_belongs_to_many :tags

      has_similar_models :authors
      has_similar_models :tags, as: :similar_posts_by_tags
      has_similar_models :authors, :tags, as: :similar_posts_by_author_or_tag
    end

    class Tag < ActiveRecord::Base
    end

    class Author < ActiveRecord::Base
      has_many :author_posts
    end

    class AuthorPosts < ActiveRecord::Base
      belongs_to :author
      belongs_to :post
    end

To return the posts with the most authors in common with `post` in descending order:

    post.similar_posts

The returned object is an ActiveRecord::Relation and so chaining of other query methods is possible:

    post.similar_posts.where('posts.created_at > ?', 10.days.ago).limit(5)

To return the posts with the most tags in common with `post` in descending order:

    post.similar_posts_by_tag

To return the posts with the most authors and tags in common with `post` in descending order:

    post.similar_posts_by_author_and_tag

The count of the associated models in common is accessible on each returned model:

    post.similar_posts_model_count
    post.similar_posts_by_tag_model_count
    post.similar_posts_by_author_and_tag_model_count

Note multiple associations do not work with sqlite.

Because of the use of `group`, pagination is not supported.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
