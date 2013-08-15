class TweetsController < ApplicationController

  respond_to :json
  
  skip_before_filter :authenticate_user!, :only => :show
  before_filter :check_twitter_user, :only => :create

  # Get tweets from twitter
  def fetch
    respond_with Tweet.fetch(params[:query].to_s, params[:options])
  end

  # Get a conversation from a tweet
  def conversation
    respond_with Tweet.conversation(params[:status_id])
  end

  # Create a tweet
  def create
    begin
      respond_with Tweet.create(:text => params[:text], :source_language => params[:source_language], :target_language => params[:target_language], :original_tweet_id => params[:original_tweet_id], :original_tweet_author => params[:original_tweet_author], :user_id => current_user.id)
    rescue Exception => e
      respond_with({ :error => e.message }, :location => '/tweets')
    end
  end

  # Full view of a tweet
  def show
    @tweet = Tweet.find_by_uuid(params[:uuid])
  end

  # Preview how a text would be tweeted (truncated and with URL)
  def preview
    respond_with({ :text => Tweet.truncate_text(params[:text].to_s, params[:author].to_s, BITLY['example']) }, :location => '/tweets')
  end

  # Get translations of a tweet
  def translations
    respond_with Tweet.translations(params[:status_id])
  end

  protected

  def check_twitter_user
    raise 'You must be signed in through Twitter in order to publish a translation' unless current_user.provider == 'twitter'
  end
end
