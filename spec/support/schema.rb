ActiveRecord::Schema.define do
  self.verbose = false

  create_table :authors, force: true do |t|
    t.timestamps null: false
  end

  create_table :author_posts, force: true do |t|
    t.integer :author_id, null: false
    t.integer :post_id, null: false
    t.timestamps null: false
  end

  create_table :posts, primary_key: :alt_id, force: true do |t|
    t.timestamps null: false
  end

  create_table :posts_tags, force: true do |t|
    t.integer :post_id, null: false
    t.integer :tag_id, null: false
  end

  create_table :tags, force: true do |t|
  end
end
