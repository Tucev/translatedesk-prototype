class AddPublishedIdToAnnotation < ActiveRecord::Migration
  def change
    add_column :annotations, :published_id, :string
  end
end
