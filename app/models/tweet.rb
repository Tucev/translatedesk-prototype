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

  # Fetch a conversation from a tweet
  # Uses an experimental method which won't be supported on 1.1 API
  # FIXME: We need a more reliable way to do this
  def self.conversation(status_id)
    begin
      require 'net/http'
      uri = URI.parse "http://api.twitter.com/1/related_results/show/#{status_id}.json"
      response = Net::HTTP.get_response uri
      data = JSON.parse response.body
      data.first['results'].collect{ |t| t['value'] }
    rescue
      []
    end
  end
end
