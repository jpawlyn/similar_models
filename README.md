# Similar Models

Adds a `similar_#{model_name.plural}` instance and class method to an active record model, but can be set to any name using `as: {method name}`.

The instance method returns models that have associated models in common ordered by most in common first.

The class method returns models ordered by most associated models in common.

If the commonality count is the same then a second order clause of `created_at` if present takes precedence.

The association(s) have to be many to many, so either [habtm](https://guides.rubyonrails.org/association_basics.html#has-and-belongs-to-many) or [has_many :through](https://guides.rubyonrails.org/association_basics.html#has-many-through).

## Installation

Add this line to your application's Gemfile:

```sh
gem 'similar_models'
```

And then execute:

```sh
$ bundle
```

## Usage

Post example

```ruby
class Post < ApplicationRecord
  has_many :author_posts
  has_many :authors, through: :author_posts
  has_and_belongs_to_many :tags

  has_similar_models :authors
  has_similar_models :tags, as: :similar_posts_by_tag
  has_similar_models :authors, :tags, as: :similar_posts_by_author_and_tag
end

class Tag < ApplicationRecord
end

class Author < ApplicationRecord
  has_many :author_posts
end

class AuthorPosts < ApplicationRecord
  belongs_to :author
  belongs_to :post
end
```

To return posts with authors in common with the `post` model by most in common first:

```ruby
post.similar_posts
```

To return posts ordered by most authors in common:
```ruby
Post.similar_posts
```

The returned object is an ActiveRecord::Relation and so chaining of other query methods is possible:

```ruby
post.similar_posts.where(created_at: 10.days.ago..).limit(5)
```

To return posts with tags in common with the `post` model by most in common first:

```ruby
post.similar_posts_by_tag
```

To return posts ordered by most tags in common:
```ruby
Post.similar_posts_by_tag
```

To return posts with the authors and tags in common with the `post` model by most in common first:

```ruby
post.similar_posts_by_author_and_tag
```

To return posts ordered by most authors and tags in common:

```ruby
Post.similar_posts_by_author_and_tag
```

The count of the associated models in common is accessible on each returned model:

```ruby
post.similar_posts_commonality_count
post.similar_posts_by_tag_commonality_count
post.similar_posts_by_author_and_tag_commonality_count
```

**Note multiple associations for the instance method do not work with sqlite.**

**Pagination is not supported on the instance method due to the use of `group by`.**

## In conjunction with acts-as-taggable-on

If you use [mbleigh/acts-as-taggable-on](https://github.com/mbleigh/acts-as-taggable-on/#usage) and want to find related users say across multiple contexts:

```ruby
user.similar_users.where(taggings: { context: %w(skills interests) })
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
