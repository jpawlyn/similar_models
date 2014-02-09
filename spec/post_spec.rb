require 'spec_helper'

describe Post do
  let(:author1) { Author.create! }
  let(:author2) { Author.create! }
  let(:author3) { Author.create! }
  let(:author4) { Author.create! }
  let(:tag1) { Tag.create! }
  let(:tag2) { Tag.create! }
  let(:tag3) { Tag.create! }
  let(:tag4) { Tag.create! }

  context 'has_many through:' do
    it 'return posts that have the most authors in common with post' do
      post = Post.create!(authors: [author1, author2, author3])
      post1 = Post.create!(authors: [author1, author4])
      post2 = Post.create!(authors: [author1, author2])
      post3 = Post.create!(authors: [author4])
      post4 = Post.create!(authors: [author1, author2, author3])

      expect(post.most_related).to eq([post4, post2, post1])
    end
  end

  context 'has_and_belongs_to_many' do
    it 'return posts that have the most tags in common with post' do
      post = Post.create!(tags: [tag1, tag2, tag3])
      post1 = Post.create!(tags: [tag1, tag4])
      post2 = Post.create!(tags: [tag1, tag2])
      post3 = Post.create!(tags: [tag4])
      post4 = Post.create!(tags: [tag1, tag2, tag3])

      expect(post.most_related_by_tags).to eq([post4, post2, post1])
    end
  end
end
