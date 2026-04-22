class OauthsController < ApplicationController
  skip_before_action :require_login, raise: false

  # Google OAuth の認証開始
  def oauth
    redirect_to sorcery_login_url(params[:provider]), allow_other_host: true
  end

  # Google OAuth のコールバック処理
  def callback
    provider = params[:provider]

    # Google OAuth で認証
    if @user = login_from(provider)
      # 既存のユーザーでログイン成功
      redirect_to root_path, notice: "#{provider.titleize}でログインしました"
    else
      # 新規ユーザーの場合
      begin
        # @user_hash を使ってユーザーを作成
        @user = create_user_from_oauth(provider)

        # ユーザー情報を保存後、自動ログイン
        reset_session
        auto_login(@user)
        # 新規ユーザーの場合は追加情報入力画面に遷移
        redirect_to complete_registration_path, notice: "#{provider.titleize}でログインしました。追加情報を入力してください"
      rescue => e
        Rails.logger.error "OAuth登録エラー: #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        # エラーが発生した場合
        redirect_to root_path, alert: "#{provider.titleize}でのログインに失敗しました"
      end
    end
  end

  private

  # Google OAuth の情報からユーザーを作成
  def create_user_from_oauth(provider)
    # @user_hash からユーザー情報を取得
    user_hash = @user_hash

    # デバッグログを出力
    Rails.logger.info "OAuth user_hash: #{user_hash.inspect}"

    # user_hash が nil の場合はエラーを発生させる
    raise "OAuth user_hash is nil" if user_hash.nil?

    # トランザクションで処理を実行
    ActiveRecord::Base.transaction do
      # ユーザーを作成
      user = User.new(
        email: user_hash[:user_info]["email"],
        nickname: user_hash[:user_info]["name"],
        first_name: "",  # 空のまま
        last_name: ""    # 空のまま
      )

      # authentications を先に build（保存はしない）
      user.authentications.build(
        provider: provider,
        uid: user_hash[:uid]
      )

      # 保存
      user.save!

      user
    end
  end
end
