Translatedesk::Application.routes.draw do
  resources :posts do
    collection do
      get 'fetch', 'conversation', 'preview', 'translations'
    end
  end
  match 'post/:uuid' => 'posts#show', :as => 'post'

  resource :machine_translation do
    collection do
      get 'translators'
      post 'translate'
    end
  end

  resources :post_drafts

  resources :dictionaries do
    collection do
      post 'words_meanings'
    end
  end

  devise_for :users, :controllers => { :omniauth_callbacks => 'omniauth_callbacks' }

  root :to => 'home#index'
  match '*page' => 'home#index'
end
