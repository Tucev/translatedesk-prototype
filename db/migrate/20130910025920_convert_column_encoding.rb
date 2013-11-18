class ConvertColumnEncoding < ActiveRecord::Migration
  def up
    # Support to Chinese characters (MySQL 5.5+ only)
    # Check: http://donpark.org/blog/2013/02/16/rails-3-2-12-not-ready-for-mysql-5-5-utf8mb4
    if ActiveRecord::Base.connection.instance_values['config'][:adapter] == 'mysql'
      execute 'ALTER TABLE posts MODIFY text TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;'
    end
  end

  def down
    # This can't be reverted
  end
end
