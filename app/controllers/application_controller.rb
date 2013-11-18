class ApplicationController < ActionController::Base

  before_filter :authenticate_user!
  before_filter :load_providers

  protect_from_forgery

  protected

  def load_providers
    @providers = Post::PROVIDERS.keys.map(&:to_s)
  end

end
