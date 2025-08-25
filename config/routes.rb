Rails.application.routes.draw do
  root "landing_pages#index"
  resource :session
  resources :passwords, param: :token
  resources :business_owners
  # resources :influencers
  get "dashboard", to: "influencers#index", as: :dashboard
  get "profile", to: "influencers#profile", as: :profile

  patch "profile_create", to: "profiles#create", as: :profile_create
  delete "/user/delete", to: "users#user_delete", as: :user_delete

end
