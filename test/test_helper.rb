ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  def create_tweet_draft(options = {})
    user = create_user
    attrs = { :user_id => user.id, :text => 'This is a draft of a tweet.', :original_tweet_id => '123456789' }.merge(options)
    td = TweetDraft.new
    td.user_id = attrs[:user_id]
    td.text = attrs[:text]
    td.original_tweet_id = attrs[:original_tweet_id]
    td.save!
    td
  end

  def create_user(options = {})
    random = (rand * 100000).to_i.to_s
    attrs = { :email => "test#{random}@localhost.localdomain", :password => '123456', :password_confirmation => '123456' }.merge(options)
    user = User.create! attrs
    user
  end

end
