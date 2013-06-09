require 'twitter'

class Tweet < ActiveRecord::Base

  # Fetch tweets from Twitter
  def self.fetch(query = '', options = {})

    query = query.to_s
    options = { :result_type => 'recent' }.merge(options)

    begin
      if query.blank?
        []
      elsif query[0] == '@'
        Twitter.user_timeline query, options
      elsif (query =~ /^[0-9]+$/).present?
        [Twitter.status(query, options)]
      else
        Twitter.search(query, options).results
      end
    rescue
      # User or tweet does not exist
      []
    end
      
  end

end
