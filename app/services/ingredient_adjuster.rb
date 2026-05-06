class IngredientAdjuster
  def initialize(ingredient, multiplier)
    @ingredient = ingredient
    @multiplier = multiplier
  end

  def call
    {
      name: name,
      amount: adjusted_amount,
      unit: translated_unit
    }
  end

  private

  def name
    @ingredient["name"] || @ingredient[:name]
  end

  def amount
    (@ingredient["amount"] || @ingredient[:amount]).to_f
  end

  def unit
    @ingredient["unit"] || @ingredient[:unit]
  end

  # 文字列キーとシンボルキーの両方に対応
  def ingredient_value(key)
    @ingredient[key] || @ingredient[key.to_sym]
  end

  def adjusted_amount
    unit = ingredient_value("unit")
    amount = ingredient_value("amount")

    case unit
    when "g", "ml"
      adjust_grams(amount)
    when "piece"
      adjust_piece(amount)
    when "tsp", "tbsp", "cup"
      adjust_teaspoon(amount)
    else
      amount
    end
  end

  def adjust_grams(amount)
    value = (amount.to_f * @multiplier).round
    round_to_5(value)
  end

  def adjust_piece(amount)
    value = amount.to_f * @multiplier
    return 1 if value < 1
    return 1 if value < 1.5
    value.round
  end

  def adjust_teaspoon(amount)
    (amount * @multiplier).round(1) # 小数点以下1桁で丸める
  end

  # 0 または 5 に丸めるメソッド
  def round_to_5(value)
  return 5 if value < 5  # 最小値を 5g にする
  
  remainder = value % 10
  
  if remainder <= 5
    value - remainder + 5  # 1~5 → 5 に丸める
  else
    value - remainder + 10  # 6~9 → 10 に丸める
  end
end

  # 　単位を日本語に
  def translated_unit
    case unit
    when "g"
      "g"
    when "piece"
      "個"
    when "tsp"
      "小さじ"
    when "tbsp"
      "大さじ"
    when "ml"
      "ml"
    when "cup"
      "カップ"
    else
      unit  # 未知の単位はそのまま返す
    end
  end
end
