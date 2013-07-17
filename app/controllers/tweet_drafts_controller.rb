class TweetDraftsController < ApplicationController
  
  respond_to :json

  def create
    saved = TweetDraft.create_or_update({ :user_id => current_user.id,
                                          :text => params[:text].to_s,
                                          :original_tweet_id => params[:original_tweet_id].to_i
                                       })
    respond_with({ :saved => saved }, :location => '/tweet_drafts')
  end

  # FIXME: Using original_tweet_id instead of id here
  def show
    respond_with TweetDraft.find_by_original_tweet_id(params[:id])
  end
end
