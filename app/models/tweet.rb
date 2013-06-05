class Tweet < ActiveRecord::Base

  # Fetch tweets from Twitter
  def self.fetch(query)
    require 'twitter'

    if query.blank?
      []
    elsif query[0] == '@'
      Twitter.user_timeline(query)
    else
      Twitter.search(query).results
    end
      
  end

end
