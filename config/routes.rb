Rails.application.routes.draw do
  root "landing_pages#index"
  resource :session
  resources :passwords, param: :token
  resources :users, only: [ :new, :create ]
  resources :business_owners
  # resources :influencers
  get "dashboard", to: "influencers#index", as: :dashboard
  get "influencer/profile", to: "influencers#profile", as: :influencer_profile

  resources :profiles, only: [:create, :update, :show]
  delete "/user/delete", to: "users#user_delete", as: :user_delete

end
