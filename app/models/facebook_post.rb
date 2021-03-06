class FacebookPost < Post
 
  self.table_name = 'posts'

  # Fetch posts from Facebook
  def self.fetch(query = '', options = {}, user = nil)
    query = query.to_s
    options[:limit] = options[:count]
    options[:fields] = 'id,from,message,created_time,shares,likes,picture,link,comments,place,name'
    
    graph = Koala::Facebook::API.new(user.facebook_oauth_token)
    results = []

    begin
      if query.blank?
        results = []
      elsif query[0] == '@'
        results = graph.get_connections(query[1..-1], 'posts', options)
      elsif (query =~ /^[0-9]+$/).present?
        # This can be the ID of a post or a page... let's see if it's a page first
        results = graph.get_connections(query, 'posts', options)
        results = [graph.get_object(query)] if results.empty?
      else
        results = graph.search(query, options)
      end

      unless results.empty?

        # Let's try to get picture and language for each user on the results
        users = {}
        results.each { |post| users[post['from']['id'].to_s] = { :locale => '', :picture => '' } }
        ids = users.keys.join(',')
        fql = graph.fql_multiquery({
          'pictures' => 'SELECT id, pic_square FROM profile WHERE id IN (%s)' % ids,
          'locales' => 'SELECT uid, locale FROM user WHERE uid IN (%s)' % ids
        })
        fql['pictures'].each { |result| users[result['id'].to_s][:picture] = result['pic_square'] }
        fql['locales'].each { |result| users[result['uid'].to_s][:locale] = result['locale'] }

        # Let's detect language for all posts or only for the ones that the provider didn't define
        texts = {}
        if options[:lang] == 'provider'
          # Fallback to Google Translate if the provider didn't define it
          results.each { |post| texts[post['id'].to_s] = post['message'] if users[post['from']['id'].to_s][:locale].blank? }
          texts = Post.auto_detect_language(texts, 'google')
        else
          results.each { |post| texts[post['id'].to_s] = post['message'] }
          texts = Post.auto_detect_language(texts, options[:lang])
        end

        # Add language and picture information for each result
        results.each do |result|
          uid = result['from']['id'].to_s
          result['lang'] = (options[:lang] == 'provider' and !users[uid][:locale].blank?) ? users[uid][:locale].gsub(/_.*$/, '') : texts[result['id'].to_s]
          result['lang_name'] = (entry = ISO_639.find(result['lang'])) ? entry.english_name : result['lang'].capitalize
          result['user_picture'] = users[uid][:picture]
        end
      end

      results
    rescue
      []
    end
  end

  # FIXME: Needs to be implemented
  def self.conversation(status_id)
    []
  end

  # Prepare a text for a Facebook post
  def self.truncate_text(text, author, url)
    text + ' ' + url
  end

  def published_url
    self.published_post_id.present? ? 'https://www.facebook.com/' + self.published_post_id : ''
  end

  def as_json(options={})
    super.as_json(options).merge({ :published_url => published_url, :author_name => user.name, :author_url => user.facebook_url, :target_language_readable => target_language_readable })
  end

  def publish
    if self.published_post_id.blank?
      graph = Koala::Facebook::API.new(self.user.facebook_oauth_token)
      response = graph.put_connections('me', FACEBOOK_CONF['namespace'] + ':translate', :message => self.truncated_text, :post => self.public_url, 'fb:explicitly_shared' => true)
      self.update_attribute(:published_post_id, response['id'].to_s)
    end
  end

  def self.supported_languages
    Rails.cache.fetch 'facebook_supported_languages' do
      require 'open-uri'
      doc = Nokogiri::HTML(open('https://www.facebook.com/translations/FacebookLocales.xml'))
      langs = {}
      doc.css('locale').each do |locale|
        name = locale.css('englishname').first.children.text
        code = locale.css('standard representation').first.children.text
        langs[code] = name
      end
      langs
    end
  end

  def publish_annotation(annotation)
    if annotation.published_id.blank? and self.published_post_id.present?
      graph = Koala::Facebook::API.new(annotation.user.facebook_oauth_token)
      response = graph.put_comment(self.published_post_id, 'Note: ' + annotation.text)
      annotation.update_attribute(:published_id, response['id'].to_s)
    end
  end
end
