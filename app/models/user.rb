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
            if: -> { first_name_required? }

  validates :last_name,
            presence: true,
            if: -> { last_name_required? }

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
    # 保存済みの authentications、または新規作成中の authentications をチェック
    if persisted?
      # 保存済みの場合は exists? でチェック
      authentications.exists?
    else
      # 新規作成中の場合は any? でチェック（メモリ上の authentications を確認）
      authentications.any?
    end
  end

  # パスワードが必要かどうかを判定
  def password_required?
  # OAuth ユーザーの場合はパスワード不要
  return false if oauth_user?

  # 新規作成時、またはパスワードが入力されている場合
  new_record? || password.present?
end

  # 姓が必要かどうかを判定
  def first_name_required?
    # カラムが存在する場合のみチェック
    return false unless self.class.column_names.include?("first_name")

    # OAuth ユーザーの場合、初回登録時(first_name が空)はスキップ
    # それ以外の場合は必須
    if oauth_user?
      persisted? && first_name_changed?
    else
      true
    end
  end

  # 名が必要かどうかを判定
  def last_name_required?
    # カラムが存在する場合のみチェック
    return false unless self.class.column_names.include?("last_name")

    # OAuth ユーザーの場合、初回登録時(last_name が空)はスキップ
    # それ以外の場合は必須
    if oauth_user?
      persisted? && last_name_changed?
    else
      true
    end
  end

  # 削除前の処理
  def transfer_recipes_to_anonymous_user
    # レシピがない場合は何もしない
    return if recipes.empty?

  # レシピ作成ユーザーのみ匿名ユーザーへ
  anonymous_user = User.unscoped.find_or_create_by!(email: "deleted_user@example.com") do |user|
    user.first_name = "削除された"
    user.last_name = "ユーザー"
    user.nickname = "不明なユーザー"

    # ランダムなパスワードを生成
    password = SecureRandom.hex(32)
    user.password = password
    user.password_confirmation = password

    # バリデーションをスキップ（匿名ユーザーは特殊なケース）
    user.save(validate: false) if user.new_record?
  end

  # レシピを匿名ユーザーに移管
  recipes.update_all(user_id: anonymous_user.id)
end
end
