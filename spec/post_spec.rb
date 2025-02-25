require 'spec_helper'

describe Post do
  let(:author1) { Author.create! }
  let(:author2) { Author.create! }
  let(:author3) { Author.create! }
  let(:author4) { Author.create! }
  let(:author5) { Author.create! }
  let(:tag1) { Tag.create! }
  let(:tag2) { Tag.create! }
  let(:tag3) { Tag.create! }
  let(:tag4) { Tag.create! }

  context 'has_many through:' do
    let!(:post)  { Post.create! authors: [author1, author2, author3] }
    let!(:post1) { Post.create! authors: [author1] }
    let!(:post2) { Post.create! authors: [author4] }
    let!(:post3) { Post.create! authors: [author1, author2, author3, author4] }
    let!(:post4) { Post.create! authors: [author5] }

    describe '.similar_posts' do
      it 'return posts ordered by most authors in common' do
        expect(described_class.similar_posts.map(&:similar_posts_commonality_count)).to eq([5, 4, 2, 1, 0])
        expect(described_class.similar_posts).to eq([post3, post, post1, post2, post4])
      end
    end

    describe '#similar_posts' do
      it 'return posts that have authors in common with `post` ordered by most in common first' do
        expect(post.similar_posts.map(&:similar_posts_commonality_count)).to eq([3, 1])
        expect(post.similar_posts).to eq([post3, post1])
      end
    end
  end

  context 'has_and_belongs_to_many' do
    let!(:post) { Post.create! tags: [tag1, tag2, tag3] }
    let!(:post1) { Post.create! tags: [tag1, tag4] }
    let!(:post2) { Post.create! tags: [tag2] }
    let!(:post3) { Post.create! tags: [tag2, tag3] }

    describe '.similar_posts_by_tag' do
      it 'return posts ordered by most tags in common' do
        expect(described_class.similar_posts_by_tag.map(&:similar_posts_by_tag_commonality_count)).to eq([4, 3, 2, 1])
        expect(described_class.similar_posts_by_tag).to eq([post, post3, post2, post1])
      end
    end

    describe '#similar_posts_by_tag' do
      it 'return posts that have tags in common with `post` ordered by most in common first' do
        expect(post.similar_posts_by_tag.map(&:similar_posts_by_tag_commonality_count)).to eq([2, 1, 1])
        expect(post.similar_posts_by_tag).to eq([post3, post2, post1])
      end
    end
  end

  context "combination of 'has_many through:' and habtm" do
    let!(:post)  { Post.create! authors: [author1, author2, author3], tags: [tag1, tag2, tag3] }
    let!(:post1) { Post.create! authors: [author1, author2, author3], tags: [tag1, tag2, tag4] }
    let!(:post2) { Post.create! authors: [author1, author4] }
    let!(:post3) { Post.create! tags: [tag4] }
    let!(:post4) { Post.create! authors: [author1], tags: [tag1, tag2, tag3] }

    describe '.similar_posts_by_author_and_tag' do
      it 'return posts ordered by most authors and tags in common' do
        expect(described_class.similar_posts_by_author_and_tag.map(&:similar_posts_by_author_and_tag_commonality_count))
          .to eq([10, 10, 8, 3, 1])
        expect(described_class.similar_posts_by_author_and_tag).to eq([post1, post, post4, post2, post3])
      end
    end

    describe '#similar_posts_by_author_and_tag' do
      it 'return posts that have authors and tags in common with `post` ordered by most in common first' do
        expect(post.similar_posts_by_author_and_tag.map(&:similar_posts_by_author_and_tag_commonality_count)).to eq([5, 4, 1])
        expect(post.similar_posts_by_author_and_tag).to eq([post1, post4, post2])
      end
    end
  end
end
