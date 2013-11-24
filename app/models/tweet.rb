require 'twitter'

class Tweet < Post
 
  self.table_name = 'posts'

  TWITTER_MAX_LENGTH = 140

  # Fetch tweets from Twitter
  def self.fetch(query = '', options = {}, user = nil)
    query = query.to_s
    options = { :result_type => 'recent' }.merge(options)
    lang_handler = options['lang']
    options.delete('lang')

    results = []
    begin
      if query.blank?
        results = []
      elsif query[0] == '@'
        results = Twitter.user_timeline query, options
      elsif (query =~ /^[0-9]+$/).present?
        results = [Twitter.status(query, options)]
      else
        results = Twitter.search(query, options).results
      end

      # Detect language
      unless lang_handler == 'provider'
        texts = {}
        results.each { |post| texts[post.id.to_s] = post.text }
        texts = Post.auto_detect_language(texts, lang_handler)
      end
      results.each do |result|
        lang = result.attrs[:lang] = lang_handler == 'provider' ? result.user.lang : texts[result.id.to_s]
        result.attrs[:lang_name] = (entry = ISO_639.find(lang)) ? entry.english_name : lang.capitalize 
      end

      results
    rescue
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

  # Return URL for a tweet. Notice: this may change over time!
  def published_url
    self.published_post_id.present? ? 'https://twitter.com/statuses/' + self.published_post_id.to_s : ''
  end

  def as_json(options={})
    super.as_json(options).merge({ :published_url => published_url, :author_name => user.name, :author_url => user.twitter_url, :target_language_readable => target_language_readable })
  end

  def publish
    Twitter.configure do |config|
      config.consumer_key = TWITTER_CONF['consumer_key']
      config.consumer_secret = TWITTER_CONF['consumer_secret']
      config.oauth_token = self.user.twitter_oauth_token
      config.oauth_token_secret = self.user.twitter_oauth_token_secret
    end
    client = Twitter::Client.new
    response = client.update(self.truncated_text, { :in_reply_to_status_id => self.original_post_id })
    self.published_post_id = response.id.to_s
  end
end
