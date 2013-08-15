# Store API configurations in constants

APIS_CONF = YAML.load_file("#{Rails.root.to_s}/config/apis.yml")[Rails.env]

# Translatedesk

TRANSLATEDESK_CONF = APIS_CONF['translatedesk']

# Twitter

TWITTER_CONF = APIS_CONF['twitter']

Twitter.configure do |config|
  config.consumer_key = TWITTER_CONF['consumer_key']
  config.consumer_secret = TWITTER_CONF['consumer_secret']
  config.oauth_token = TWITTER_CONF['oauth_token']
  config.oauth_token_secret = TWITTER_CONF['oauth_token_secret']
end

# Google Translate

GOOGLE_TRANSLATE_API_KEY = APIS_CONF['google_translate']

# Bing Translate

BING_CLIENT_ID = APIS_CONF['bing_translate']['client_id']
BING_CLIENT_SECRET = APIS_CONF['bing_translate']['client_secret']

# Bit.ly

BITLY = APIS_CONF['bitly']
