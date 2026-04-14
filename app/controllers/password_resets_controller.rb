class PasswordResetsController < ApplicationController
  skip_before_action :require_login

  # パスワードリセット申請フォーム
  def new
  end


  # パスワードリセットメール送信
  def create
    @user = User.find_by(email: params[:email])

    # セキュリティのため、メールアドレスの存在に関わらず同じメッセージを表示
    @user&.deliver_reset_password_instructions!

    redirect_to login_path, notice: "パスワードリセットのメールを送信しました。メールをご確認ください。"
  end


  # パスワード変更フォーム
  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)

    if @user.blank?
      redirect_to root_path, alert: "無効なトークンです"
    end
  end

  # パスワード更新
  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(@token)

    if @user.blank?
      redirect_to root_path, alert: "無効なトークンです"
      return
    end

    @user.password_confirmation = params[:user][:password_confirmation]

    if @user.change_password(params[:user][:password])
      redirect_to login_path, notice: "パスワードが変更されました"
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end
end
