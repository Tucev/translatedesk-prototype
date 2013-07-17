class TweetDraft < ActiveRecord::Base
  belongs_to :user
  attr_accessible :text, :original_tweet_id

  validates :user_id, :uniqueness => { :scope => :original_tweet_id }
  validates_presence_of :user_id, :original_tweet_id, :text

  def self.create_or_update(params)
    return false if params[:user_id].blank? or params[:text].blank? or params[:original_tweet_id].blank?

    draft = TweetDraft.find_by_user_id_and_original_tweet_id params[:user_id], params[:original_tweet_id]
    
    if draft.nil?
      draft = TweetDraft.new
      draft.user_id = params[:user_id]
      draft.original_tweet_id = params[:original_tweet_id]
    end

    draft.text = params[:text]

    draft.save
  end
end
