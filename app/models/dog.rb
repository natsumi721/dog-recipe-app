class Dog < ApplicationRecord
  belongs_to :user, optional: true

  # アレルギー情報(表示用)
  ALLERGIES = [
    "牛肉", "鶏肉", "豚肉", "牛乳", "チーズ", "ヨーグルト",
    "卵", "鹿肉", "納豆(大豆)", "鮭", "マグロ", "タラ"
  ].freeze

  # 犬のサイズ
  SIZES = [
    "小型犬", "中型犬", "大型犬"
  ].freeze

  # 日本語 → 英語タグ変換
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
    "魚" => "fish",
    "米" => "rice",
    "雑穀米" => "grain"
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

  has_one_attached :avatar

  validates :name, presence: true
  validates :size, presence: true
  validates :age_stage, presence: true
  validates :body_type, presence: true
  validates :activity_level, presence: true
  validates :avatar,
            content_type: { in: %w[image/png image/jpeg image/webp] },
            size: { less_than: 5.megabytes, message: "画像は5MB以下にしてください" }

  # 推奨レシピを取得
  def recommended_recipes
    recipes = Recipe.published.to_a

    # アレルギー取得
    allergies_list = parse_allergies  

    # タグに変換
    allergy_tags = allergies_list.map { |a| ALLERGY_MAP[a] }.compact

    # アレルギーを含むレシピを除外
    recipes = recipes.reject do |recipe|
      recipe_has_allergen?(recipe, allergy_tags)
    end

    # スコアリング
    scored = recipes.map do |recipe|
      score = 0
      score += 1 if recipe.age_stage == age_stage
      score += 1 if recipe.body_type == body_type
      score += 1 if recipe.activity_level == activity_level
      [recipe, score]
    end

    # 上位取得
    top_recipes = scored
                    .sort_by { |_, score| -score }
                    .map(&:first)
                    .take(20)

    top_recipes.sample(5)
  end

  # アレルギー情報を日本語で表示
  def allergies_i18n
    return "なし" if allergies.blank?

    list = allergies.is_a?(String) ? [allergies] : allergies

    list.map do |allergy|
      I18n.t("enums.dog.allergy.#{allergy}", default: allergy)
    end.join(", ")
  end

  private

  # アレルギーを配列に変換
  def parse_allergies
    return [] if allergies.blank?

    # 文字列の場合はカンマで分割、配列の場合はそのまま
    if allergies.is_a?(String)
      allergies.split(",").map(&:strip)
    else
      allergies
    end
  end

  # レシピがアレルゲンを含むか確認
  def recipe_has_allergen?(recipe, allergy_tags)
    # 全サイズの材料を取得
    ingredients = recipe.ingredients_json.values.flatten

    # 材料のタグとアレルギータグを照合
    ingredients.any? do |ingredient|
      ingredient_tags = ingredient["tags"] || []
      (allergy_tags & ingredient_tags).any?  # 共通要素があるか?
    end
  end
end