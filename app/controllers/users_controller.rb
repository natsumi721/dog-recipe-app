class UsersController < ApplicationController
  skip_before_action :require_login

  def new
    @user = User.new
    @user.dogs.build
  end

  def create
    @user = User.new(user_params)

    # 画像が添付されていれば処理
    if params[:user][:dogs_attributes]&.dig("0", :avatar).present?
      processed_image = ImageProcessor.process(
        params[:user][:dogs_attributes]["0"][:avatar]
      )

      if processed_image
        # 処理済み画像をパラメータに再設定
        params[:user][:dogs_attributes]["0"][:avatar] = processed_image
      end
    end

    if @user.save
      auto_login(@user) # ログイン状態にする
      redirect_to root_path, notice: "登録ありがとうございます！次に愛犬の情報を登録してください。"
    else
      flash.now[:danger] = "ユーザー登録に失敗しました"
      render :new
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      redirect_to root_path, notice: "ユーザー情報を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # 削除確認画面
  def confirm_destroy
    @user = current_user
  end

  # 実際の削除処理
  def destroy
    @user = current_user

    # ユーザーを削除（関連データも自動削除される）
    @user.destroy!

    # セッションをクリア
    logout

    redirect_to root_path, notice: "アカウントを削除しました。ご利用ありがとうございました。"
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to edit_user_path(@user), alert: "アカウントの削除に失敗しました。もう一度お試しください。"
  end

  private

    def user_params
      params.require(:user).permit(:first_name, :last_name, :nickname, :email, :password, :password_confirmation)
    end
end
