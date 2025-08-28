Rails.application.routes.draw do
  root "landing_pages#index"
  resource :session
  resources :passwords, param: :token
  resources :users, only: [ :new, :create ]
  resources :business_owners
  # resources :influencers
  get "dashboard", to: "influencers#index", as: :dashboard
  get "influencer/profile", to: "influencers#profile", as: :influencer_profile

  resources :profiles, only: [ :create, :update, :show ]
  delete "/user/delete", to: "users#user_delete", as: :user_delete


  get "/meta_connects/connect", to: "meta_connects#connect"       # Step 1: redirect to Meta OAuth
  get "/meta_connects/callback", to: "meta_connects#callback"     # Step 2: handle callback
  get "/meta_connects/profile", to: "meta_connects#profile"       # Step 3: fetch IG profile

  get "youtube_connects/connect", to: "youtube_connects#connect"
  get "youtube_connects/callback", to: "youtube_connects#callback"
  get "youtube_connects/profile", to: "youtube_connects#profile"
end
