TWITTER_CONF = YAML.load_file("#{Rails.root.to_s}/config/twitter.yml")[Rails.env]

Twitter.configure do |config|
  config.consumer_key = TWITTER_CONF['consumer_key']
  config.consumer_secret = TWITTER_CONF['consumer_secret']
  config.oauth_token = TWITTER_CONF['oauth_token']
  config.oauth_token_secret = TWITTER_CONF['oauth_token_secret']
end
