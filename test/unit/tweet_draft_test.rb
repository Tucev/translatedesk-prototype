require File.expand_path('../../test_helper', __FILE__)
 
class TweetDraftTest < ActiveSupport::TestCase

  test "a user should not have more than one draft for the same tweet" do
    user = create_user
    assert_difference 'TweetDraft.count' do
      create_tweet_draft :user_id => user.id, :original_tweet_id => 123456789
    end
    assert_no_difference 'TweetDraft.count' do
      assert_raise ActiveRecord::RecordInvalid do
        create_tweet_draft :user_id => user.id, :original_tweet_id => 123456789
      end
    end
  end 

  test "a user can have multiple drafts for different tweets" do
    user = create_user
    assert_difference 'TweetDraft.count' do
      create_tweet_draft :user_id => user.id, :original_tweet_id => 123456789
    end
    assert_difference 'TweetDraft.count' do
      create_tweet_draft :user_id => user.id, :original_tweet_id => 987654321
    end
  end

  test "create draft if it does not exist yet and update if it does exist" do
    user = create_user
    assert_difference 'TweetDraft.count' do
      assert TweetDraft.create_or_update(:user_id => user.id, :text => 'Test', :original_tweet_id => 123456789)
      assert_equal 'Test', TweetDraft.last.text
    end
    assert_no_difference 'TweetDraft.count' do
      assert TweetDraft.create_or_update(:user_id => user.id, :text => 'Updated', :original_tweet_id => 123456789)
      assert_equal 'Updated', TweetDraft.last.text
    end
  end

  test "return false if some parameter is not supplied to create_or_update" do
    user = create_user
    refute TweetDraft.create_or_update(:text => 'Updated', :original_tweet_id => 123456789)
    refute TweetDraft.create_or_update(:user_id => user.id, :original_tweet_id => 123456789)
    refute TweetDraft.create_or_update(:user_id => user.id, :text => 'Updated')
  end

end
