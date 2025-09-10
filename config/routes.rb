Rails.application.routes.draw do
  root "landing_pages#index"
  get "/service", to: "landing_pages#service"
  get "/support", to: "landing_pages#support"
  get "/policy", to: "landing_pages#policy"
  get "/aboutus", to: "landing_pages#aboutus"
  get "messages/create"
  get "conversations/index"
  get "conversations/show"
  resource :session
  get "/auth/:provider/callback", to: "sessions#omniauth"
  get  '/complete_google_signup',  to: 'sessions#complete_google_signup',  as: :complete_google_signup
  post '/finalize_google_signup',  to: 'sessions#finalize_google_signup',  as: :finalize_google_signup

  get "/auth/failure", to: redirect("/")
  resources :passwords, param: :token
  resources :users do
    get 'confirm', on: :collection
  end
  resources :business_owners
  resources :campaigns

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

  resources :twitter_connects, only: [] do
  collection do
    get :connect
    get :callback
    get :profile
  end
end

  resources :conversations, only: [:index, :show, :new, :create] do
    resources :messages, only: [:create]
  end

  get "chat", to: "conversations#index", as: :chat

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

   match '*path', to: 'application#not_found', via: :all, constraints: lambda { |req|
    !req.path.starts_with?('/rails/active_storage')
  }
end
