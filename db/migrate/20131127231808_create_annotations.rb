class CreateAnnotations < ActiveRecord::Migration
  def change
    create_table :annotations do |t|
      t.references :post
      t.references :user
      t.text :text

      t.timestamps
    end
    add_index :annotations, :post_id
    add_index :annotations, :user_id
  end
end
