class Recipe < ApplicationRecord
  attr_accessor :adjusted_multiplier
  belongs_to :user, optional: true


  enum :age_stage, { puppy: 0, adult: 1, senior: 2 }, prefix: true
  enum :body_type, { thin: 0, normal: 1, overweight: 2 }, prefix: true
  enum :activity_level, { low: 0, medium: 1, high: 2 }, prefix: true
  enum status: { draft: 0, published: 1, rejected: 2 }

  include EnumI18n
  enum_i18n :size
  enum_i18n :age_stage
  enum_i18n :body_type
  enum_i18n :activity_level

  validates :name, presence: true
  validates :description, presence: true
  validates :instructions, presence: true
  validates :nutrition_note, presence: true
  validates :age_stage, presence: true
  validates :body_type, presence: true
  validates :activity_level, presence: true

  validate :ingredients_presence


  has_many :bookmarks, dependent: :destroy
  has_many :bookmarked_by_users, through: :bookmarks, source: :user

  # アレルギータグを配列として扱う
  serialize :allergy_tags, coder: YAML, type: Array

  # 保存前に自動的に空白を除去
  before_save :remove_blank_allergy_tags

  # JSON文字列をパースする
  before_validation :parse_ingredients_json

  # サイズ別の材料を取得するメソッド（テキスト形式用）
  def ingredients_for_size(size)
    return "" if ingredients.blank?

    lines = ingredients.split("\n")

    size_patterns = case size.to_sym
    when :small then [ "■ 小型犬", "▪ 小型犬" ]
    when :medium then [ "■ 中型犬", "▪ 中型犬" ]
    when :large then [ "■ 大型犬", "▪ 大型犬" ]
    else return ""
    end

    in_section = false
    result_lines = []

    lines.each do |line|
      if size_patterns.any? { |pattern| line.include?(pattern) }
        in_section = true
        next
      end

      if in_section && line.strip.start_with?("■")
        break
      end

      if in_section && line.strip.present?
        result_lines << line.strip
      end
    end

    result_lines.join("\n")
  end

  # 材料の見出し部分を取得
  def ingredients_header
    return "" if ingredients.blank?
    lines = ingredients.split("\n")
    lines.first&.strip || ""
  end

  # medium を基準に、small と large を計算で求める
  def base_ingredients
    return {} unless json_format?

    medium_ingredients = ingredients_json["medium"] || ingredients_json[:medium]
    return {} if medium_ingredients.blank?

    {
      "small" => calculate_size_ingredients(medium_ingredients, 0.8, :small),
      "medium" => medium_ingredients,
      "large" => calculate_size_ingredients(medium_ingredients, 1.2, :large)
    }
  end

  # 材料データの形式を判定
  def ingredients_format
    ingredients_json.present? ? :json : :text
  end

  # JSON形式かどうか
  def json_format?
    ingredients_format == :json
  end

  # TEXT形式かどうか
  def text_format?
    ingredients_format == :text
  end

  # 全サイズの材料を犬の情報に基づいて調整して返す
  def all_adjusted_ingredients(dog)
    return nil unless json_format?
    return {} if dog.nil?

    multiplier = calculate_multiplier(dog)

    {
      small: adjust_ingredients_for_size(:small, multiplier),
      medium: adjust_ingredients_for_size(:medium, multiplier),
      large: adjust_ingredients_for_size(:large, multiplier)
    }
  end

  # 犬の情報に基づいて調整された材料を返す（特定サイズ）
  def adjusted_ingredients(dog, size, meals: 4)
    return nil unless json_format?
    return [] if dog.nil?

    multiplier = calculate_multiplier(dog)
    ingredients = adjust_ingredients_for_size(size, multiplier)

    # 上限制御を追加（食数を指定可能）
    ingredients = apply_topping_cap(ingredients, dog, size, meals: meals)

    # ② 各材料を丸める
    ingredients.map do |ingredient|
      round_ingredient(ingredient)
    end
  end

  # multiplierを計算
  def calculate_multiplier(dog)
    multiplier = 1.0

    # 年齢による調整
    multiplier *= 1.2 if dog.age_stage_puppy?
    multiplier *= 0.85 if dog.age_stage_senior?

    # 体型による調整
    multiplier *= 1.2 if dog.body_type_thin?
    multiplier *= 0.9 if dog.body_type_overweight?

    # 運動量による調整
    multiplier *= 1.2 if dog.activity_level_high?
    multiplier *= 0.9 if dog.activity_level_low?

    multiplier
  end

  private

  def parse_ingredients_json
    # ingredients_json が文字列の場合、パースする
    if ingredients_json.is_a?(String)
      begin
        self.ingredients_json = JSON.parse(ingredients_json)
      rescue JSON::ParserError
        # パースに失敗した場合は空のハッシュにする
        self.ingredients_json = {}
      end
    end
  end

  # 既存のバリデーション（1つに統一）
  def ingredients_presence
    return if ingredients_json.blank?

    ingredients = ingredients_json["medium"]
    return if ingredients.blank?

    # HashでもArrayでも対応
    ingredients = ingredients.values if ingredients.is_a?(Hash)

    valid = ingredients.any? do |i|
      i["name"].present? && i["amount"].present?
    end

    errors.add(:ingredients_json, "に有効な材料を1つ以上入力してください") unless valid
  end

  # 指定サイズの材料を調整
  def adjust_ingredients_for_size(size, multiplier)
    ingredients_list = base_ingredients[size.to_s] || base_ingredients[size]
    return [] if ingredients_list.blank?

    ingredients_list.map do |ingredient|
      IngredientAdjuster.new(ingredient, multiplier).call
    end
  end

  # サイズに応じた材料を計算
  def calculate_size_ingredients(ingredients, multiplier, size)
    ingredients = ingredients.values if ingredients.is_a?(Hash)
    ingredients.map do |ingredient|
      adjusted_ingredient = ingredient.dup
      adjusted_ingredient["amount"] = calculate_amount(
        ingredient["amount"] || ingredient[:amount],
        ingredient["unit"] || ingredient[:unit],
        ingredient,  # ★ 材料データ全体を渡す
        multiplier,
        size
      )
      adjusted_ingredient
    end
  end

  # 単位に応じた量の計算
  def calculate_amount(amount, unit, ingredient_data, multiplier, size)
    case unit
    when "g"
      (amount.to_f * multiplier).round

    when "piece"
      # 卵だけ特別扱い
      if egg_ingredient?(ingredient_data)
        case size.to_sym
        when :large
          2
        else
          1
        end
      else
        value = amount.to_f * multiplier
        value.round
      end

    when "tsp"
      (amount.to_f * multiplier).round(1)
    when "tbsp"
      (amount.to_f * multiplier).round(1)
    when "ml"
      (amount.to_f * multiplier).round
    else
      amount
    end
  end

  # 卵かどうかを判定（タグ + 材料名）
  def egg_ingredient?(ingredient_data)
    # タグで判定
    tags = ingredient_data["tags"] || ingredient_data[:tags]
    return true if tags.present? && tags.include?("egg")

    # タグがない場合は材料名で判定
    name = ingredient_data["name"] || ingredient_data[:name]
    return false if name.blank?

    egg_keywords = [ "卵", "たまご", "タマゴ", "玉子", "ゆで卵", "卵黄", "卵白" ]
    egg_keywords.any? { |keyword| name.include?(keyword) }
  end

  # allergy_tags の空白を除去
  def remove_blank_allergy_tags
    # allergy_tags が nil または空の場合は空の配列にする
    self.allergy_tags = allergy_tags&.reject(&:blank?) || []
  end

    # 材料を丸めるメソッド
  def round_ingredient(ingredient)
    unit = ingredient[:unit]
    amount = ingredient[:amount].to_f

    rounded_amount = case unit
   when "g", "ml"
      round_to_5(amount).to_i
    when "個"
      adjust_piece(amount).to_i
    when "小さじ", "大さじ", "カップ"
      amount.round(1)
    else
      amount
    end

    ingredient.merge(amount: rounded_amount)
  end

  # 0 または 5 に丸めるメソッド（IngredientAdjuster と同じロジック）
  def round_to_5(value)
    return 5 if value < 5  # 最小値を 5g にする
  
    remainder = value % 10
  
    if remainder <= 5
      value - remainder + 5  # 1~5 → 5 に丸める
    else
      value - remainder + 10  # 6~9 → 10 に丸める
    end
  end

  # piece（個）の調整
  def adjust_piece(amount)
    value = amount.to_f
    return 1 if value < 1
    return 1 if value < 1.5
    value.round
  end


  def apply_topping_cap(ingredients, dog, size, meals: 4)
  #  トッピング総量を計算
  estimated_meal_amount = estimate_meal_amount(size)

  total_topping = ingredients.sum { |i| i[:amount].to_f }

  # 1食量を推定
  meal_amount = estimate_meal_amount(size)

  #  指定食数分の1食量を計算
  total_meal_amount = meal_amount * meals

  #  上限を決定（指定食数分の20％まで）
  max_ratio = 0.2
  max_topping = total_meal_amount * max_ratio

  #  丸め処理で増える分を事前に見込む
  buffer = ingredients.size * 2.5
  adjusted_max = max_topping - buffer

  #  調整後の目標値に収める
  if total_topping > adjusted_max
    scale = adjusted_max / total_topping

    ingredients.each do |ingredient|
      ingredient[:amount] = ingredient[:amount].to_f * scale
    end
  end

  ingredients
end

  def estimate_meal_amount(size)
    # サイズ基準の基本量
    base_amount = case size.to_sym
    when :small then 80   # g
    when :medium then 250  # g
    when :large then 550   # g
    else 200
    end
    base_amount
  end
end
