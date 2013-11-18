class AddFacebookTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :facebook_oauth_token, :string
  end
end
