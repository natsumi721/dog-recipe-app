class User < ApplicationRecord
  authenticates_with_sorcery!

  # アソシエーション
  has_many :dogs, dependent: :destroy
  has_many :recipes, dependent: :nullify  # 作成レシピは残したい
  has_many :bookmarks, dependent: :destroy
  has_many :bookmark_recipes, through: :bookmarks, source: :recipe
  has_one :dog, dependent: :destroy
  has_many :authentications, dependent: :destroy   # Authenticationモデルとの関連付け
  accepts_nested_attributes_for :authentications

  # ネストした属性を許可
  accepts_nested_attributes_for :dogs

  # デフォルトスコープで削除済みユーザーを除外
  default_scope { where(deleted_at: nil) } if column_names.include?("deleted_at")

  # バリデーション
  validates :email, presence: true, uniqueness: true

  # パスワードのバリデーション（通常のパスワード認証の場合のみ）
  validates :password,
            length: { minimum: 8, message: "は8文字以上で入力してください" },
            if: :password_required?

  validates :password,
            format: {
              with: /\A(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]+\z/,
              message: "は英字と数字を組み合わせてください"
            },
            if: :password_required?

  validates :password,
            confirmation: true,
            if: :password_required?

  validates :password_confirmation,
            presence: true,
            if: :password_required?

  # ニックネームのバリデーション（OAuth ユーザーまたは管理者でない場合のみ必須）
  validates :nickname,
            presence: true,
            unless: -> { admin? || oauth_user? }

  # 姓・名のバリデーション（OAuth ユーザーでない場合のみ必須）
  # ※ first_name, last_name カラムが存在する場合のみ有効にしてください
  validates :first_name,
            presence: true,
            unless: :oauth_user?,
            if: -> { self.class.column_names.include?('first_name') }

  validates :last_name,
            presence: true,
            unless: :oauth_user?,
            if: -> { self.class.column_names.include?('last_name') }

  # コールバック
  before_destroy :transfer_recipes_to_anonymous_user

  # 論理削除メソッド
  def soft_delete
    update(deleted_at: Time.current)
  end

  # 削除済みかどうか
  def deleted?
    deleted_at.present?
  end

  private

  # OAuth ユーザーかどうかを判定
  def oauth_user?
    authentications.any?
  end

  # パスワードが必要かどうかを判定
  def password_required?
    # 新規作成時で、かつ OAuth ユーザーでない場合
    # または、パスワードが変更される場合
    (new_record? && !oauth_user?) || changes[:crypted_password]
  end

  # 削除前の処理
  def transfer_recipes_to_anonymous_user
    # レシピがない場合は何もしない
    return if recipes.empty?

    # レシピ作成ユーザーのみ匿名ユーザーへ
    anonymous_user = User.find_or_create_by!(email: "deleted_user@example.com") do |user|
      user.name = "削除されたユーザー"
      user.nickname = "不明なユーザー"
      user.password = SecureRandom.hex(32)
      user.password_confirmation = user.password
    end

    # レシピを匿名ユーザーに移管
    recipes.update_all(user_id: anonymous_user.id)
  end
end