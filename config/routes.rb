Rails.application.routes.draw do
  get "profiles/edit"
  get "profiles/update"
  get "oauths/oauth"
  get "oauths/callback"
  get "static_pages/privacy_policy"
  get "static_pages/terms_of_service"
  get "password_resets/new"
  get "password_resets/edit"


  # 開発環境でのみメールプレビュー機能を有効化
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # ユーザー登録
  get "signup", to: "users#new"
  post "users", to: "users#create"

  # ユーザー情報
  resource :user, only: [ :edit, :update, :destroy  ] do
    member do
      get :confirm_destroy  # 削除確認画面
    end
  end

  # ログイン後のダッシュボード
  get "dashboard", to: "homes#dashboard"

  # ログイン・ログアウト
  get "login", to: "user_sessions#new"
  post "login", to: "user_sessions#create"
  delete "logout", to: "user_sessions#destroy"

  resource :profile, only: [ :edit, :update ]

  # Google OAuth のルーティング
  post "oauth/callback", to: "oauths#callback"
  get "oauth/callback", to: "oauths#callback"
  get "oauth/:provider", to: "oauths#oauth", as: :auth_at_provider

  # OAuth 追加情報入力
  get "complete_registration", to: "users#complete_registration", as: :complete_registration
  patch "complete_registration", to: "users#update_registration", as: :update_registration

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # トップページ
  root "homes#top"
  # 使い方
  get "how_to", to: "homes#how_to"

  # プライバシーポリシー
  get "privacy_policy", to: "static_pages#privacy_policy"
  get "terms_of_service", to: "static_pages#terms_of_service"

  # プロフィール変更
  resource :user, only: [ :edit, :update ]


  # 愛犬情報
  resources :dogs, except: [ :show ] do
    collection do
      get :select_dog  # 愛犬選択画面(情報変更用)
      get :complete, action: :complete, as: :complete_guest  # ゲスト用
    end
    member do
      get :complete
    end
  end

  # レシピ
  resources :recipes, only: [ :new, :create, :index, :show ] do
    collection do
      get :select_dog  # 愛犬選択画面(レシピ閲覧用)
      get :bookmarks   # ブックマーク
      get :my_recipes   # マイレシピ
      get :select_action
      post :confirm  # レシピ公開前の確認画面
    end
  end

  resources :bookmarks, only: %i[create destroy]

    # 管理者画面
    namespace :admin do
    resources :recipes, only: [ :index, :show, :update ] do
      collection do
        get :published  # 承認済みレシピ一覧
      end
      get "dashboard", to: "dashboard#index"
  end
end


    # パスワードリセット
    resources :password_resets, only: [ :new, :create, :edit, :update ]
end
