class IngredientAdjuster
  def initialize(ingredient, multiplier)
    @ingredient = ingredient
    @multiplier = multiplier
  end

  def call
    adjusted_amount = adjust_amount
    @ingredient.merge(amount: adjusted_amount)
  end

  private

  def adjust_amount
    case @ingredient[:unit]
    when "g"
      (@ingredient[:amount] * @multiplier).round

    when "piece"
      adjust_piece

    when "tsp"
      (@ingredient[:amount] * @multiplier).round(1)

    else
      @ingredient[:amount]
    end
  end

  #  卵とか
  def adjust_piece
    value = @ingredient[:amount] * @multiplier

    if value < 1
      1
    elsif value < 1.5
      1
    else
      value.round
    end
  end
end