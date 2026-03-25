class HomesController < ApplicationController
    skip_before_action :require_login, only: [ :top ]
    skip_before_action :check_dog_profile, only: [ :top ]

    def top
      Recipe.update_all(status: 1)
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
end
