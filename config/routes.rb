Translatedesk::Application.routes.draw do
  resources :tweets do
    collection do
      get 'fetch' 
    end
  end

  devise_for :users
  root :to => "home#index"
  match "*page" => "home#index"
end
