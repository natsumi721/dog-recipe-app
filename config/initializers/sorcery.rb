Rails.application.config.sorcery.submodules = [ :reset_password, :external ]

Rails.application.config.sorcery.configure do |config|
  config.external_providers = [ :google ]

  # Google OAuth設定
  config.google.key = ENV["GOOGLE_CLIENT_ID"]
  config.google.secret = ENV["GOOGLE_CLIENT_SECRET"]
  config.google.callback_url = "http://localhost:3000/oauth/callback?provider=google"
  config.google.user_info_mapping = {
    email: "email",
    name: "name"
  }

  config.user_config do |user|
    # reset_password モジュールの設定
    user.reset_password_token_attribute_name = :reset_password_token
    user.reset_password_token_expires_at_attribute_name = :reset_password_token_expires_at
    user.reset_password_email_sent_at_attribute_name = :reset_password_email_sent_at
    user.reset_password_mailer = UserMailer
    user.reset_password_expiration_period = 86400
    user.reset_password_time_between_emails = 300

    # external モジュールの設定
    user.authentications_class = Authentication

    # テスト環境用の設定
    user.stretches = 1 if Rails.env.test?
  end

  # ユーザークラスの指定
  config.user_class = "User"
end
