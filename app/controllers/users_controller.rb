class UsersController < ApplicationController
  skip_before_action :require_login

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      auto_login(@user) # ログイン状態にする
      redirect_to root_path, notice: "登録ありがとうございます！次に愛犬の情報を登録してください。"
    else
      render :new
    end
  end

  private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :nickname, :email, :password, :password_confirmation)
    end
end
