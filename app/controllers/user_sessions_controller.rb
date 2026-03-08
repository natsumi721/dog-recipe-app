class UserSessionsController < ApplicationController
  # ログイン前のアクションのみスキップ
  skip_before_action :require_login, only: %i[new create]
  skip_before_action :check_dog_profile, only: %i[new create destroy]

  def new
  end

  def create
    @user = login(params[:email], params[:password])

    if @user
      # 愛犬情報があればレシピページへ、なければ愛犬情報登録へ
      if @user.dogs.exists?
        dog = @user.dogs.first # 最後に使用した愛犬情報
        redirect_to recipes_path(dog_id: dog.id), notice: "ログインしました"
      else
        redirect_to new_dog_path, notice: "愛犬の情報を登録してください"
      end
    else
      flash.now[:alert] = "ログイン情報が違います"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to root_path, notice: "ログアウトしました"
  end
end
