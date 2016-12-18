# MostRelated

`most_related` returns models that have the most associated models in common

## Installation

Add this line to your application's Gemfile:

    gem 'most_related'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install most_related

## Usage

Post example

    class Post < ActiveRecord::Base
      has_most_related :authors
      has_most_related :tags, as: :most_related_by_tags
      has_most_related [:authors, :tags], as: :most_related_by_author_or_tag

      has_many :author_posts
      has_many :authors, through: :author_posts
    end

    class Author < ActiveRecord::Base
      has_many :author_posts
    end

    class AuthorPosts < ActiveRecord::Base
      belongs_to :author
      belongs_to :post
    end

To return the posts with the most authors in common with post, in descending order:

    post.most_related

To return the posts with the most tags in common with post, in descending order:

    post.most_related_by_tag

To return the posts with the most authors and tags in common with post, in descending order:

    post.most_related_by_author_or_tag

The count of the many to many associated models in common is accessible on each returned model

    post.most_related_count
    post.most_related_by_tag_count
    post.most_related_by_author_or_tag_count

If multiple many to many associations are used, the syntax is specific to MySql although
it could be made to work with Postgres.

Because of the use of 'group', pagination is not supported.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
