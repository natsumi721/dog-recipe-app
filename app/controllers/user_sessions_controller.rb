class UserSessionsController < ApplicationController
  # ログイン前のアクションのみスキップ
  skip_before_action :require_login, only: %i[new create]
  skip_before_action :check_dog_profile, only: %i[new create destroy]

  def new
  end

  def create
      @user = login(params[:email], params[:password])

    if @user
      # ログイン成功: ダッシュボードへ
      redirect_to dashboard_path, notice: "ログインしました"
    else
      # ログイン失敗: ログイン画面を再表示
      flash.now[:alert] = "ログイン情報が違います"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to root_path, notice: "ログアウトしました"
  end
end
