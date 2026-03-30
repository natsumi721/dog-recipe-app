class Dog < ApplicationRecord
  belongs_to :user, optional: true
  serialize :allergies, coder: JSON, type: Array

  # アレルギー情報（表示用）
  ALLERGIES = [
    "牛肉", "鶏肉", "豚肉", "牛乳", "チーズ", "ヨーグルト",
    "卵", "鹿肉", "納豆(大豆)", "鮭", "マグロ", "タラ"
  ].freeze

  # 👇 追加：日本語 → 英語タグ変換
  ALLERGY_MAP = {
    "牛肉" => "beef",
    "鶏肉" => "chicken",
    "豚肉" => "pork",
    "牛乳" => "milk",
    "チーズ" => "dairy",
    "ヨーグルト" => "dairy",
    "卵" => "egg",
    "鹿肉" => "venison",
    "納豆(大豆)" => "soy",
    "鮭" => "salmon",
    "マグロ" => "tuna",
    "タラ" => "cod"
  }.freeze

  enum :size, { small: 0, medium: 1, large: 2 }, prefix: true
  enum :age_stage, { puppy: 0, adult: 1, senior: 2 }, prefix: true
  enum :body_type, { thin: 0, normal: 1, overweight: 2 }, prefix: true
  enum :activity_level, { low: 0, medium: 1, high: 2 }, prefix: true

  include EnumI18n
  enum_i18n :size
  enum_i18n :age_stage
  enum_i18n :body_type
  enum_i18n :activity_level

  validates :name, presence: true
  validates :size, presence: true
  validates :age_stage, presence: true
  validates :body_type, presence: true
  validates :activity_level, presence: true

  def recommended_recipes
    recipes = Recipe.published.to_a

    # 🔥 アレルギー除外（TEXT + JSON + tag対応）
    if allergies.present?
      recipes = recipes.reject do |recipe|
        allergies.any? do |a|
          tag = ALLERGY_MAP[a]

          if recipe.ingredients_json.present?
            ingredients = recipe.ingredients_json.values.flatten

            ingredients.any? do |ing|
              ing["name"]&.include?(a) ||
              (tag && ing["tags"]&.include?(tag))
            end

          elsif recipe.ingredients.present?
            recipe.ingredients.include?(a) ||
            recipe.ingredients.include?(a.gsub("肉", ""))

          else
            false
          end
        end
      end
    end

    # スコアリング
    scored = recipes.map do |recipe|
      score = 0
      score += 1 if recipe.age_stage == age_stage
      score += 1 if recipe.body_type == body_type
      score += 1 if recipe.activity_level == activity_level
      [ recipe, score ]
    end

    # 上位取得
    top_recipes = scored
                    .sort_by { |_, score| -score }
                    .map(&:first)
                    .take(20)

    top_recipes = top_recipes.sample(5)

    # 調整
    top_recipes.map do |recipe|
      adjusted = RecipeAdjuster.new(recipe, self).call
      PortionAdjuster.new(adjusted, self).call
    end
  end

  def allergies_i18n
    return "なし" if allergies.blank?

    allergies.map { |allergy| I18n.t("enums.dog.allergy.#{allergy}", default: allergy) }.join(", ")
  end
end