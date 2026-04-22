class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  before_action :require_login
  before_action :check_user_registration, if: -> { logged_in? }, unless: :skip_user_check?
  before_action :check_dog_profile, if: -> { logged_in? }, unless: :skip_dog_check?

  private

  # ユーザーの姓名が未入力の場合、追加情報入力画面にリダイレクト
  def check_user_registration
    return unless logged_in?
    return if current_user.admin?

    # 姓名が未入力の場合、追加情報入力画面にリダイレクト
    if current_user.first_name.blank? || current_user.last_name.blank?
      unless controller_name == 'users' && action_name.in?(%w[complete_registration update_registration])
        redirect_to complete_registration_path, alert: '追加情報を入力してください'
      end
    end
  end

  # 愛犬情報が未登録の場合、愛犬登録画面にリダイレクト
  def check_dog_profile
    return unless logged_in?
    return if current_user.admin?

    # 姓名が未入力の場合はスキップ(先に姓名を入力させる)
    return if current_user.first_name.blank? || current_user.last_name.blank?

    # 愛犬情報がない場合のみ愛犬登録ページへ
    return unless current_user.dogs.empty?
    return if controller_name.in?(%w[dogs user_sessions])

    redirect_to new_dog_path, alert: '犬のプロフィールを登録してください'
  end

  # ユーザーチェックをスキップする条件
  def skip_user_check?
    # OAuth コントローラーではスキップ
    controller_name == 'oauths' ||
    # ログアウト時はスキップ
    (controller_name == 'user_sessions' && action_name == 'destroy')
  end

  # 愛犬チェックをスキップする条件
  def skip_dog_check?
    # OAuth コントローラーではスキップ
    controller_name == 'oauths' ||
    # ログアウト時はスキップ
    (controller_name == 'user_sessions' && action_name == 'destroy') ||
    # ユーザー登録画面ではスキップ
    (controller_name == 'users' && action_name.in?(%w[complete_registration update_registration]))
  end

  def not_authenticated
    # ログインが必要なページにアクセスした際の処理
    redirect_to login_path, alert: t('defaults.flash_message.require_login')
  end
end