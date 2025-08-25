Rails.application.routes.draw do
  root "landing_pages#index"
  resource :session
  resources :passwords, param: :token
  resources :business_owners
  # resources :influencers
  get "dashboard", to: "influencers#index", as: :dashboard
  get "profile", to: "influencers#profile", as: :profile
end
