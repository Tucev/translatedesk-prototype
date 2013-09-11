class User < ActiveRecord::Base

  has_many :tweets, :dependent => :destroy
  has_many :tweet_drafts, :dependent => :destroy

  # Include default devise modules
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me

  validates_presence_of :name

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
      user.name = auth['info'].name
      user.provider = auth.provider
      user.uid = auth.uid
      user.twitter_oauth_token = auth.credentials.token
      user.twitter_oauth_token_secret = auth.credentials.secret
    end
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def password_required?
    super && provider.blank?
  end

  def twitter_url
    (self.provider == 'twitter' and self.uid.present?) ? 'https://twitter.com/account/redirect_by_id?id=' + self.uid.to_s : '' 
  end

  # Do not output sensible attributes, like passwords or tokens
  def as_json(options = {})
    {
      name: self.name,
      email: self.email
    }
  end

end
