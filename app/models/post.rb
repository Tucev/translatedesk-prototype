class Post < ActiveRecord::Base

  PROVIDERS = {
    :twitter => Tweet,
    :facebook => FacebookPost
  }

  belongs_to :user

  attr_accessible :original_text, :text, :original_post_id, :original_post_author, :source_language, :target_language, :user_id, :provider
  attr_accessor :original_post_author

  validates_presence_of :truncated_text, :original_post_id, :original_post_author, :text, :user_id, :provider
  validates_uniqueness_of :uuid

  before_validation :generate_uuid, :on => :create
  before_validation :preprocess, :on => :create
  before_validation :publish, :on => :create
  after_create :remove_draft

  def self.fetch(query = '', options = {})
    Post.all options
  end

  def self.conversation(post_id)
    [Post.find(post_id)]
  end

  # Prepare a text for a post
  def self.truncate_text(text, author, url)
    full_text = text =~ /^TT / ? text : 'TT ' + text
    full_text = full_text =~ /^TT @#{author} / ? full_text : full_text.gsub(/^TT /, 'TT @' + author + ' ')
    full_text + ' ' + url
  end

  def self.translations(post_id, provider = nil)
    self.all :conditions => { :original_post_id => post_id, :provider => provider }
  end

  def target_language_readable
    (entry = ISO_639.find(self.target_language)) ? entry.english_name : self.target_language
  end

  def as_json(options={})
    super.as_json(options).merge({ :author_name => user.name, :target_language_readable => target_language_readable })
  end

  def published_url
    ''
  end

  protected

  def generate_uuid
    begin
      self.uuid = SecureRandom.uuid
    end while self.class.exists?(:uuid => self.uuid)
  end

  def preprocess
    if self.text.present?
      # FIXME: Is there a better way to get the path/link in the model? Because we are breaking MVC here... also look for a better way to get the host
      full_url = Rails.application.routes.url_helpers.post_path(self.uuid, :only_path => false, :host => TRANSLATEDESK_CONF['public_host'])
      bitly = Bitly.new(BITLY['username'], BITLY['api_key'])
      url = bitly.shorten(full_url, :history => 1)
      self.truncated_text = Post.truncate_text(self.text, self.original_post_author, url.short_url)
    end
  end

  def publish
    # By default, we just store in the database
  end

  def remove_draft
    PostDraft.destroy_all :user_id => self.user_id, :original_post_id => self.original_post_id, :provider => self.provider
  end

end
