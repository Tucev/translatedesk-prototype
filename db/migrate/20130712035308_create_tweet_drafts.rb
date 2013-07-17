class CreateTweetDrafts < ActiveRecord::Migration
  def change
    create_table :tweet_drafts do |t|
      t.references :user
      t.text :text
      t.string :original_tweet_id

      t.timestamps
    end
    add_index :tweet_drafts, :user_id
  end
end
