Rails.application.routes.draw do
  # 不要な行を削除
  # get "user_sessions/new"
  # get "user_sessions/create"
  # get "user_sessions/destroy"
  # get "users/new"
  # get "users/create"
  # get "dogs/new"
  # get "dogs/creat"

  # ユーザー登録
  get "signup", to: "users#new"
  post "users", to: "users#create"

  # ログイン・ログアウト
  get "login", to: "user_sessions#new"
  post "login", to: "user_sessions#create"
  delete "logout", to: "user_sessions#destroy"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # トップページ
  root "homes#top"

  # 愛犬情報
  resources :dogs do
    member do
      get :complete
    end
  end

  # レシピ
  resources :recipes, only: [ :index, :show ]
end