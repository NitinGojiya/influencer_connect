Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
 root "landing_pages#index"
end
