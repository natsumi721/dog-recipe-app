module ApplicationHelper
    def hide_auth_links?
    # ログイン画面や新規登録画面では認証リンクを非表示にする
    controller_name == "sessions" ||
    (controller_name == "users" && action_name == "new")
  end

  def default_meta_tags
    {
      site: "One Wan Dish",
      title: "愛犬のためのレシピ提案アプリ",
      reverse: true,
      charset: "utf-8",
      description: "愛犬の身体に合わせたレシピを提案します",
      canonical: request.original_url,
      separator: "|",
      og: {
        site_name: "One Wan Dish",
        title: "One Wan Dish",
       description: "愛犬の身体に合わせたレシピを提案します",
        type: "website",
        url: request.original_url,
        image: image_url("ogp.png"),
        locale: "ja_JP"
      },
      twitter: {
        card: "summary_large_image"
      }
    }
  end
end
