module ApplicationHelper

    def hide_auth_links?
    # ログイン画面や新規登録画面では認証リンクを非表示にする
    controller_name == 'sessions' || 
    (controller_name == 'users' && action_name == 'new')
  end
end
