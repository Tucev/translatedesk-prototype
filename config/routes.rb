Translatedesk::Application.routes.draw do
  resources :tweets do
    collection do
      get 'fetch', 'conversation', 'preview', 'translations'
    end
  end
  match 'tweet/:uuid' => 'tweets#show', :as => 'tweet'

  resource :machine_translation do
    collection do
      get 'translators'
      post 'translate'
    end
  end

  resources :tweet_drafts

  devise_for :users, :controllers => { :omniauth_callbacks => 'omniauth_callbacks' }

  root :to => "home#index"
  match "*page" => "home#index"
end
