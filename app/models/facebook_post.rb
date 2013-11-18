class FacebookPost < Post
 
  self.table_name = 'posts'

  # Fetch posts from Facebook
  def self.fetch(query = '', options = {}, user = nil)
    query = query.to_s
    options[:limit] = options[:count]
    options = {}.merge(options)
    
    graph = Koala::Facebook::API.new(user.facebook_oauth_token)

    begin
      if query.blank?
        []
      else
        graph.search(query, options)
      end
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

end
