Rails.application.routes.draw do
  root "landing_pages#index"
  resource :session
  resources :passwords, param: :token
  resources :business_owners
end
