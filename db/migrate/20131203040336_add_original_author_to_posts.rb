class AddOriginalAuthorToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :original_post_author, :text
  end
end
