require 'twitter'

class Tweet < ActiveRecord::Base

  TWITTER_MAX_LENGTH = 140

  belongs_to :user

  attr_accessible :text, :original_tweet_id, :original_tweet_author, :source_language, :target_language, :user_id
  attr_accessor :original_tweet_author

  validates_presence_of :truncated_text, :original_tweet_id, :original_tweet_author, :text, :user_id 
  validates_uniqueness_of :uuid

  before_validation :generate_uuid, :on => :create
  before_validation :preprocess_tweet, :on => :create
  before_validation :publish_on_twitter, :on => :create
  after_create :remove_draft

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
      # Not working anymore
      # require 'net/http'
      # uri = URI.parse "http://api.twitter.com/1.1/related_results/show/#{status_id}.json"
      # response = Net::HTTP.get_response uri
      # data = JSON.parse response.body
      # data.first['results'].collect{ |t| t['value'] }
      # FIXME Check if this suggestion is a good solution:
      # https://github.com/sferik/twitter/issues/299#issuecomment-7429430
      tweets = []
      while status_id.present? do
        tweet = Twitter.status status_id
        tweets << tweet
        status_id = tweet[:in_reply_to_status_id]
      end
      tweets
    rescue
      []
    end
  end

  # Prepare a text for tweet
  def self.truncate_text(text, author, url)
    full_text = text =~ /^TT / ? text : 'TT ' + text
    full_text = full_text =~ /^TT @#{author} / ? full_text : full_text.gsub(/^TT /, 'TT @' + author + ' ')
    full_text = full_text.truncate(TWITTER_MAX_LENGTH - url.length, :separator => ' ', :omission => '... ')
    full_text + ' ' + url
  end

  # FIXME: Better if this is a named_scope?
  def self.translations(status_id)
    Tweet.all :conditions => { :original_tweet_id => status_id }
  end

  # Return URL for a tweet. Notice: this may change over time!
  def twitter_url
    self.published_tweet_id.present? ? 'https://twitter.com/statuses/' + self.published_tweet_id.to_s : ''
  end

  # Return URL for a tweet from the API. Notice: this may change over time!
  def api_twitter_url
    self.original_tweet_id.present? ? 'https://twitter.com/twitterapi/status/' + self.original_tweet_id.to_s : ''
  end

  def target_language_readable
    (entry = ISO_639.find(self.target_language)) ? entry.english_name : self.target_language
  end

  def as_json(options={})
    super.as_json(options).merge({ :twitter_url => twitter_url, :author_name => user.name, :author_url => user.twitter_url, :target_language_readable => target_language_readable })
  end

  protected

  def generate_uuid
    begin
      self.uuid = SecureRandom.uuid
    end while self.class.exists?(:uuid => self.uuid)
  end

  def preprocess_tweet
    if self.text.present?
      # FIXME: Is there a better way to get the path/link in the model? Because we are breaking MVC here... also look for a better way to get the host
      full_url = Rails.application.routes.url_helpers.tweet_path(self.uuid, :only_path => false, :host => TRANSLATEDESK_CONF['public_host'])
      bitly = Bitly.new(BITLY['username'], BITLY['api_key'])
      url = bitly.shorten(full_url, :history => 1)
      self.truncated_text = Tweet.truncate_text(self.text, self.original_tweet_author, url.short_url)
    end
  end

  def publish_on_twitter
    Twitter.configure do |config|
      config.consumer_key = TWITTER_CONF['consumer_key']
      config.consumer_secret = TWITTER_CONF['consumer_secret']
      config.oauth_token = self.user.twitter_oauth_token
      config.oauth_token_secret = self.user.twitter_oauth_token_secret
    end
    client = Twitter::Client.new
    response = client.update(self.truncated_text, { :in_reply_to_status_id => self.original_tweet_id })
    self.published_tweet_id = response.id.to_s
  end

  def remove_draft
    TweetDraft.destroy_all :user_id => self.user_id, :original_tweet_id => self.original_tweet_id
  end

end
