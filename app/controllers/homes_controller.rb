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
      #  N+1問題を解決: avatar_attachment を事前読み込み
    @dogs = @user.dogs.includes(:avatar_attachment)
    
    # 画像が登録されている犬だけを取得
    @dogs_with_avatar = @dogs.select { |dog| dog.avatar.attached? }
    end

    def show
      @dogs = current_user.dogs.includes(:avatar_attachment)
    end

    def how_to
    end
end
