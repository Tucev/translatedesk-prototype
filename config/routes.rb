Translatedesk::Application.routes.draw do
  resources :tweets do
    collection do
      get 'fetch', 'conversation'
    end
  end

  resource :machine_translation do
    collection do
      get 'translators'
      post 'translate'
    end
  end

  resources :tweet_drafts

  devise_for :users

  root :to => "home#index"
  match "*page" => "home#index"
end
