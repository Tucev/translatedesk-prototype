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
        results = graph.get_connections(query[1..-1], 'feed', options)
      elsif (query =~ /^[0-9]+$/).present?
        # This can be the ID of a post or a page... let's see if it's a page first
        results = graph.get_connections(query, 'feed', options)
        results = [graph.get_object(query)] if results.empty?
      else
        results = graph.search(query, options)
      end

      unless results.empty?
        # Workaround to get the locale and picture
        # FIXME: Look for a better approach
        texts = {}
        unless options[:lang] == 'provider'
          results.each { |post| texts[post['id'].to_s] = post['message'] }
          texts = Post.auto_detect_language(texts, options[:lang])
        end

        users = {}
        results.each { |post| users[post['from']['id'].to_s] = { :locale => '', :picture => '' } }

        graph.fql_query('SELECT uid, locale, pic_square FROM user WHERE uid IN (%s)' % users.keys.join(',')).each do |result|
          users[result['uid'].to_s] = { :locale => result['locale'], :picture => result['pic_square'] }
        end

        results.each do |result|
          uid = result['from']['id'].to_s
          result['lang'] = options[:lang] == 'provider' ? users[uid][:locale].gsub(/_.*$/, '') : texts[result['id'].to_s]
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
    full_text = text =~ /^TT / ? text : 'TT ' + text
    full_text = full_text =~ /^TT #{author}: / ? full_text : full_text.gsub(/^TT /, 'TT ' + author + ': ')
    full_text + ' ' + url
  end

  def published_url
    if self.published_post_id.present?
      id, story = self.published_post_id.split('_')
      "https://www.facebook.com/permalink.php?story_fbid=#{story}&id=#{id}"
    else
      ''
    end
  end

  def as_json(options={})
    super.as_json(options).merge({ :published_url => published_url, :author_name => user.name, :author_url => user.facebook_url, :target_language_readable => target_language_readable })
  end

  def publish
    graph = Koala::Facebook::API.new(self.user.facebook_oauth_token)
    response = graph.put_connections('me', 'feed', :message => self.truncated_text)
    self.published_post_id = response['id'].to_s
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
end
