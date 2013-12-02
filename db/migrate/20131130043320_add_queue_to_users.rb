class AddQueueToUsers < ActiveRecord::Migration
  def change
    add_column :users, :queue, :text, :limit => 16777215 # Medium text
  end
end
