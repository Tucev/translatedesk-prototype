class Post < ActiveRecord::Base

  PROVIDERS = {
    :twitter => Tweet,
    :facebook => FacebookPost
  }

  belongs_to :user
  has_many :annotations

  attr_accessible :original_text, :text, :original_post_id, :original_post_author, :source_language, :target_language, :user_id, :provider

  validates_presence_of :truncated_text, :original_post_id, :original_post_author, :text, :user_id, :provider
  validates_uniqueness_of :uuid

  before_validation :generate_uuid, :on => :create
  before_validation :preprocess, :on => :create
  after_commit :publish, :on => :create
  after_commit :remove_draft, :on => :create

  serialize :original_post_author, Hash

  def self.fetch(query = '', options = {}, user = nil)
    Post.all options
  end

  def self.conversation(post_id)
    [Post.find(post_id)]
  end

  # Prepare a text for a post
  def self.truncate_text(text, author, url)
    text + ' ' + url
  end

  def self.translations(post_id, provider = nil)
    self.all :conditions => { :original_post_id => post_id, :provider => provider }
  end

  def self.auto_detect_language(text = {}, handler = 'langid')
    # Each text should be uniquely identified
    if text.is_a?(Array)
      hash = {}
      text.each_with_index{ |t, i| hash[i] = t }
      text = hash
    elsif text.is_a?(String)
      text = { 0 => text }
    end

    case handler
    when 'google'
      # FIXME: Not doing batch detection for the time being because of the limits... but the library already
      #        supports that, just pass an array instead of a string
      text.each{ |i, t| text[i] = GoogleTranslate.detect(t).first }
    when 'langid'
      if %x[which langid]
        text.each do |i, t|
          io = IO.popen('langid', 'w+')
          io.puts t
          io.close_write
          text[i] = io.gets.match(/\('([^']+)', .*/)[1]
        end
      else
        text.each{ |i, t| text[i] = '' }
      end
    else
      text.each{ |i, t| text[i] = '' }
    end

    text
  end

  def target_language_readable
    (entry = ISO_639.find(self.target_language)) ? entry.english_name : self.target_language
  end

  def as_json(options={})
    super.as_json(options).merge({ :author_name => user.name,
                                   :target_language_readable => target_language_readable,
                                   :annotations => annotations })
  end

  def published_url
    ''
  end

  def public_url
    # FIXME: Is there a better way to get the path/link in the model? Because we are breaking MVC here... also look for a better way to get the host
    Rails.application.routes.url_helpers.post_path(self.uuid, :only_path => false, :host => TRANSLATEDESK_CONF['public_host'])
  end

  protected

  def generate_uuid
    begin
      self.uuid = SecureRandom.uuid
    end while self.class.exists?(:uuid => self.uuid)
  end

  def preprocess
    if self.text.present?
      bitly = Bitly.new(BITLY['username'], BITLY['api_key'])
      url = bitly.shorten(self.public_url, :history => 1)
      self.truncated_text = Post.truncate_text(self.text, self.original_post_author, url.short_url)
    end
  end

  def publish
    # By default, we just store in the database
  end

  def remove_draft
    PostDraft.destroy_all(:user_id => self.user_id, :original_post_id => self.original_post_id, :provider => self.provider) if self.published_post_id
  end

end
