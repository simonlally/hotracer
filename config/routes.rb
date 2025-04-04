Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  get "up" => "rails/health#show", as: :rails_health_check

  resources :races, only: [ :index, :new, :create, :show, :update ]
  resources :participations
  root "races#index"
end
