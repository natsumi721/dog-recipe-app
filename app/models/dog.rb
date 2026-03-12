class Dog < ApplicationRecord
  belongs_to :user, optional: true
  serialize :allergies, type: Array, coder: YAML

  # アレルギー情報を定数として定義
  ALLERGIES = [
    "牛肉", "鶏肉", "豚肉", "牛乳", "チーズ", "ヨーグルト",
    "卵", "鹿肉", "納豆(大豆)", "鮭", "マグロ", "タラ"
  ].freeze

  enum :size, { small: 0, medium: 1, large: 2 }, prefix: true
  enum :age_stage, { puppy: 0, adult: 1, senior: 2 }, prefix: true
  enum :body_type, { thin: 0, normal: 1, overweight: 2 }, prefix: true
  enum :activity_level, { low: 0, medium: 1, high: 2 }, prefix: true

  include EnumI18n
  # enum の日本語化を有効にする
  enum_i18n :size
  enum_i18n :age_stage
  enum_i18n :body_type
  enum_i18n :activity_level

  validates :name, presence: true
  validates :size, presence: true
  validates :age_stage, presence: true
  validates :body_type, presence: true
  validates :activity_level, presence: true

  attribute :allergies, :string, array: true, default: []

  def recommended_recipes
  recipes = Recipe.where(
    age_stage: age_stage,
    body_type: body_type,
    activity_level: activity_level
  )

  return recipes.order("RANDOM()").limit(3) unless allergies.present?

    recipes = recipes.to_a.reject do |recipe|
      allergies.any? do |a|
        base = a.gsub("肉", "")
        recipe.ingredients.include?(base)
      end
    end

    recipes.sample(3)
  end

  def allergies_i18n
    return "なし" if allergies.blank?

    allergies.map { |allergy| I18n.t("enums.dog.allergy.#{allergy}", default: allergy) }.join(", ")
  end
end
