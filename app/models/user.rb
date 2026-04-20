class User < ApplicationRecord
  authenticates_with_sorcery!


  # バリデーション
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 8, message: "は8文字以上で入力してください" },
            if: -> { new_record? || changes[:crypted_password] }
  validates :password,
            format: {
            with: /\A(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]+\z/,
            message: "は英字と数字を組み合わせてください"
          },
            if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :nickname, presence: true, unless: :admin?

    has_many :dogs, dependent: :destroy
    has_many :recipes, dependent: :nullify  # 作成レシピは残したい
    has_many :bookmarks, dependent: :destroy
    has_many :bookmark_recipes, through: :bookmarks, source: :recipe
    has_one :dog, dependent: :destroy

    # 削除前の処理
    before_destroy :transfer_recipes_to_anonymous_user

    # ネストした属性を許可
    accepts_nested_attributes_for :dogs

    # デフォルトスコープで削除済みユーザーを除外
    default_scope { where(deleted_at: nil) } if column_names.include?("deleted_at")

    # 論理削除メソッド
    def soft_delete
      update(deleted_at: Time.current)
    end

    # 削除済みかどうか
    def deleted?
      deleted_at.present?
    end
    private

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
