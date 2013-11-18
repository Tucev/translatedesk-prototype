require File.expand_path('../../test_helper', __FILE__)
 
class PostDraftTest < ActiveSupport::TestCase

  test "a user should not have more than one draft for the same post and same provider" do
    user = create_user
    assert_difference('PostDraft.count', 2) do
      create_post_draft :user_id => user.id, :original_post_id => 123456789, :provider => 'twitter'
      create_post_draft :user_id => user.id, :original_post_id => 123456789, :provider => 'facebook'
    end
    assert_no_difference 'PostDraft.count' do
      assert_raise ActiveRecord::RecordInvalid do
        create_post_draft :user_id => user.id, :original_post_id => 123456789, :provider => 'twitter'
      end
    end
  end 

  test "a user can have multiple drafts for different posts" do
    user = create_user
    assert_difference 'PostDraft.count' do
      create_post_draft :user_id => user.id, :original_post_id => 123456789
    end
    assert_difference 'PostDraft.count' do
      create_post_draft :user_id => user.id, :original_post_id => 987654321
    end
  end

  test "create draft if it does not exist yet and update if it does exist" do
    user = create_user
    assert_difference 'PostDraft.count' do
      assert PostDraft.create_or_update(:user_id => user.id, :text => 'Test', :original_post_id => 123456789, :provider => 'twitter')
      assert_equal 'Test', PostDraft.last.text
    end
    assert_no_difference 'PostDraft.count' do
      assert PostDraft.create_or_update(:user_id => user.id, :text => 'Updated', :original_post_id => 123456789, :provider => 'twitter')
      assert_equal 'Updated', PostDraft.last.text
    end
  end

  test "return false if some parameter is not supplied to create_or_update" do
    user = create_user
    refute PostDraft.create_or_update(:text => 'Updated', :original_post_id => 123456789)
    refute PostDraft.create_or_update(:user_id => user.id, :original_post_id => 123456789)
    refute PostDraft.create_or_update(:user_id => user.id, :text => 'Updated')
    refute PostDraft.create_or_update(:user_id => user.id, :original_post_id => 123456789, :text => 'Updated')
  end

end
