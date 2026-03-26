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
  recipes = Recipe.published.to_a

    # ① アレルギー除外（暫定）
    if allergies.present?
      recipes = recipes.reject do |recipe|
        allergies.any? do |a|
          recipe.ingredients.include?(a) ||
          recipe.ingredients.include?(a.gsub("肉", ""))
        end
      end
    end

    # ② スコアリング
    scored = recipes.map do |recipe|
      score = 0
      score += 1 if recipe.age_stage == age_stage
      score += 1 if recipe.body_type == body_type
      score += 1 if recipe.activity_level == activity_level
      [recipe, score]
    end

    # ③ スコア順で並べて上位取得
    top_recipes = scored
                    .sort_by { |_, score| -score }
                    .map(&:first)
                    .take(5)

    # ④ レシピを犬に合わせて調整
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
