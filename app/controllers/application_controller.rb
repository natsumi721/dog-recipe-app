class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :require_login
  before_action :check_dog_profile, if: -> { logged_in? }, unless: :skip_dog_check?

  private

  def check_dog_profile
    return unless logged_in?
    return if current_user.admin?
    # ログイン済みで、愛犬情報がない場合のみ愛犬登録ページへ
    return unless current_user.dogs.empty?
    return if controller_name.in?(%w[dogs user_sessions])

    redirect_to new_dog_path
  end

  def skip_dog_check?
    # ログアウト時は愛犬チェックをスキップ
    controller_name == "user_sessions" && action_name == "destroy"
  end

  def not_authenticated
    # ログインが必要なページにアクセスした際の処理
    redirect_to login_path, alert: t("defaults.flash_message.require_login")
  end
end
