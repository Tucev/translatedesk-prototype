class TweetsController < ApplicationController

  respond_to :json

  # Get tweets from twitter
  def fetch
    respond_with Tweet.fetch(params[:query].to_s)
  end

end
