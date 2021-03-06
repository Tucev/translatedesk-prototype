# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131204224535) do

  create_table "annotations", :force => true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.text     "text"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "published_id"
  end

  add_index "annotations", ["post_id"], :name => "index_annotations_on_post_id"
  add_index "annotations", ["user_id"], :name => "index_annotations_on_user_id"

  create_table "post_drafts", :force => true do |t|
    t.integer  "user_id"
    t.text     "text"
    t.string   "original_post_id"
    t.string   "provider"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "post_drafts", ["user_id"], :name => "index_post_drafts_on_user_id"

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.text     "original_text"
    t.text     "text"
    t.text     "truncated_text"
    t.string   "original_post_id"
    t.string   "published_post_id"
    t.string   "provider"
    t.string   "source_language"
    t.string   "target_language"
    t.string   "uuid"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
    t.text     "original_post_author"
  end

  add_index "posts", ["original_post_id"], :name => "index_posts_on_original_post_id"
  add_index "posts", ["published_post_id"], :name => "index_posts_on_published_post_id"
  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"
  add_index "posts", ["uuid"], :name => "index_posts_on_uuid"

  create_table "users", :force => true do |t|
    t.string   "email",                                          :default => "", :null => false
    t.string   "encrypted_password",                             :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                  :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                     :null => false
    t.datetime "updated_at",                                                     :null => false
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "twitter_oauth_token"
    t.string   "twitter_oauth_token_secret"
    t.string   "facebook_oauth_token"
    t.text     "queue",                      :limit => 16777215
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
