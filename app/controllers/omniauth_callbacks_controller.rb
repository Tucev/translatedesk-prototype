class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    user = User.from_omniauth(request.env['omniauth.auth'])
    if user.persisted?
      flash.notice = 'Signed in'
      sign_in_and_redirect user
    else
      session['devise.user_attributes'] = user.attributes
      redirect_to '/register_finish'
    end    
  end

  # It's possible to add new providers here (Facebook, etc.)
  alias_method :twitter, :all
end
