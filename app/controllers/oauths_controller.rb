class OauthsController < ApplicationController
  skip_before_action :require_login, raise: false

  # Google OAuth の認証開始
  def oauth
  # Google OAuth の認証URLを取得してリダイレクト
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
        # Google OAuth の情報を取得
        @user = create_from(provider)
        
        # ユーザー情報を保存
        reset_session
        auto_login(@user)
        redirect_to root_path, notice: "#{provider.titleize}でログインしました"
      rescue
        # エラーが発生した場合
        redirect_to root_path, alert: "#{provider.titleize}でのログインに失敗しました"
      end
    end
  end

  private

  # Google OAuth の情報からユーザーを作成
  def create_from(provider)
  user_info = sorcery_fetch_user_hash(provider)
  
  #  トランザクションで処理を実行
  ActiveRecord::Base.transaction do
    #  ユーザーを作成（姓・名は空のまま）
    user = User.new(
      email: user_info[:user_info]['email'],
      nickname: user_info[:user_info]['name'],
      first_name: '',  #  空のまま
      last_name: ''    #  空のまま
    )
    
    # バリデーションをスキップせずに保存
    # （条件付きバリデーションにより、姓・名のバリデーションはスキップされる）
    user.save!
    
    #  Authentication レコードを作成
    user.authentications.create!(
      provider: provider,
      uid: user_info[:uid]
    )
    
    user
  end
end
end