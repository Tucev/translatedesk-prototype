class TweetsController < ApplicationController

  respond_to :json

  # Get tweets from twitter
  def fetch
    respond_with Tweet.fetch(params[:query].to_s, params[:options])
  end

  # Get a conversation from a tweet
  def conversation
    respond_with Tweet.conversation(params[:status_id])
  end
end
