require 'twitter'

class Tweet < ActiveRecord::Base

  # Fetch tweets from Twitter
  def self.fetch(query = '')

    query = query.to_s

    begin
      if query.blank?
        []
      elsif query[0] == '@'
        Twitter.user_timeline query
      elsif (query =~ /^[0-9]+$/).present?
        [Twitter.status(query)]
      else
        Twitter.search(query).results
      end
    rescue
      # User or tweet does not exist
      []
    end
      
  end

end
