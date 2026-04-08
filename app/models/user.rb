class User < ApplicationRecord
  authenticates_with_sorcery!


  # バリデーション
  validates :email, presence: true, uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }
  validates :nickname, presence: true, unless: :admin?

    has_many :dogs, dependent: :destroy
    has_many :recipes, dependent: :destroy
    has_many :bookmarks, dependent: :destroy
    has_many :bookmark_recipes, through: :bookmarks, source: :recipe
    has_one :dog, dependent: :destroy


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
end
