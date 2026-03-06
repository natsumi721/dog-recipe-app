Rails.application.routes.draw do
  get "user_sessions/new"
  get "user_sessions/create"
  get "user_sessions/destroy"
  get "users/new"
  get "users/create"
  get "dogs/new"
  get "dogs/creat"

  get "signup", to: "users#new"
  post "users", to: "users#create"

  get "login", to: "user_sessions#new"
  post "login", to: "user_sessions#create"
  delete "logout", to: "user_sessions#destroy"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
  root "homes#top"
  resources :dogs, only: %i[new create]
  resources :recipes, only: [ :index, :show ]
  resources :dogs do
    member do
      get :complete
    end
  end
end
