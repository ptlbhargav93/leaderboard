Rails.application.routes.draw do
  root to: "home#index"
  get '/history', to: 'home#match_history'
  resources :matches
  resources :players
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
