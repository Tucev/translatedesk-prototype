Translatedesk::Application.routes.draw do
  resources :tweets do
    collection do
      get 'fetch', 'conversation'
    end
  end

  resources :tweet_drafts

  devise_for :users
  root :to => "home#index"
  match "*page" => "home#index"
end
