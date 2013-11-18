class CreatePostDrafts < ActiveRecord::Migration
  def change
    create_table :post_drafts do |t|
      t.references :user
      t.text :text
      t.string :original_post_id
      t.string :provider

      t.timestamps
    end
    add_index :post_drafts, :user_id
  end
end
