class HomesController < ApplicationController
    skip_before_action :require_login, only: [ :top, :how_to ]
    skip_before_action :check_dog_profile, only: [ :top ]

    def top
      # ログイン済みの場合はダッシュボードへ
      redirect_to dashboard_path if logged_in?
    end

    # ログイン後のメニュー選択画面
    def dashboard
      @user = current_user
      @dogs = @user.dogs
    end

    def show
      @dogs = current_user.dogs
    end

    def how_to
    end
end
