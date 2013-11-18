class CreatePosts < ActiveRecord::Migration
  def up
    create_table :posts do |t|
      t.references :user
      t.text :original_text       # Original, untranslated text
      t.text :text                # Translated text
      t.text :truncated_text      # Translated text truncated, and with TT, user name and URL
      t.string :original_post_id  # Original post (remote) from which this one is a translation
      t.string :published_post_id # Real published post
      t.string :provider
      t.string :source_language
      t.string :target_language
      t.string :uuid, :unique => true

      t.timestamps
    end
    add_index :posts, :user_id
    add_index :posts, :original_post_id
    add_index :posts, :published_post_id
    add_index :posts, :uuid
  end

  def down
    drop_table :posts
  end
end
