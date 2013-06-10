require File.expand_path('../../test_helper', __FILE__)
 
class TweetTest < ActiveSupport::TestCase

  test "fetch nothing when no query is provided" do
    assert_equal [], Tweet.fetch
  end

  test "fetch a timeline with 20 tweets when a user profile is provided" do
    list = Tweet.fetch('@meedan')
    assert_equal 20, list.size
    assert_equal ['meedan'], list.map(&:from_user).uniq
  end

  test "fetch a status when a numeric string is provided" do
    list = Tweet.fetch(342256739451801600)
    assert_equal 1, list.size
    assert_instance_of Twitter::Tweet, list.first
  end

  test "fetch a search result when a hashtag is provided" do
    list = Tweet.fetch('#ruby')
    assert_equal list, list.select{ |t| t.text =~ /#ruby/i }
  end

  test "fetch a search result when any other string is provided" do
    list = Tweet.fetch('meedan')
    assert_equal list, list.select{ |t| t.text =~ /meedan/i or t.from_user == 'meedan' }
  end

  test "fetch nothing when user does not exist" do
    assert_nothing_raised do
      assert_equal [], Tweet.fetch('@meedanfake')
    end
  end

  test "fetch nothing when tweet status does not exist" do
    assert_nothing_raised do
      assert_equal [], Tweet.fetch(5)
    end
  end

  test "fetch custom amount of tweets when provided" do
    assert_equal 1, Tweet.fetch(342256739451801600, { :count => 50 }).size
    assert_equal 50, Tweet.fetch('ruby', { :count => 50 }).size
    assert_equal 50, Tweet.fetch('@meedan', { :count => 50 }).size
  end

  test "load a conversation for a tweet" do
    assert_equal [], Tweet.conversation(342256739451801600)
    conversation = Tweet.conversation(306023092684214273)
    assert_kind_of Array, conversation
    assert_equal 2, conversation.size
  end

end
