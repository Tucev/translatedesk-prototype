class CreateTweets < ActiveRecord::Migration
  def up
    create_table :tweets do |t|
      t.references :user
      t.text :text
      t.text :truncated_text
      t.string :original_tweet_id # Original tweet from which this one is a translation
      t.string :published_tweet_id # Real published tweet
      t.string :source_language
      t.string :target_language
      t.string :uuid, :unique => true

      t.timestamps
    end
    add_index :tweets, :user_id
    add_index :tweets, :original_tweet_id
    add_index :tweets, :published_tweet_id
    add_index :tweets, :uuid
  end

  def down
    drop_table :tweets
  end
end
