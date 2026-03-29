require 'rails_helper'

RSpec.describe IngredientAdjuster do
  describe '#call' do
    context 'piece単位の場合' do
      it '0.5個未満は1個になる' do
        ingredient = { name: "卵", amount: 1, unit: "piece" }
        adjuster = IngredientAdjuster.new(ingredient, 0.3)
        result = adjuster.call

        expect(result[:amount]).to eq(1)
      end

      it '1.3個は1個になる' do
        ingredient = { name: "卵", amount: 1, unit: "piece" }
        adjuster = IngredientAdjuster.new(ingredient, 1.3)
        result = adjuster.call

        expect(result[:amount]).to eq(1)
      end

      it '1.8個は2個になる' do
        ingredient = { name: "卵", amount: 1, unit: "piece" }
        adjuster = IngredientAdjuster.new(ingredient, 1.8)
        result = adjuster.call

        expect(result[:amount]).to eq(2)
      end
    end

    context 'g単位の場合' do
      it '整数に丸められる' do
        ingredient = { name: "鶏肉", amount: 100, unit: "g" }
        adjuster = IngredientAdjuster.new(ingredient, 1.3)
        result = adjuster.call

        expect(result[:amount]).to eq(130)
      end
    end

    context 'tsp単位の場合' do
      it '小数第1位まで表示される' do
        ingredient = { name: "塩", amount: 1, unit: "tsp" }
        adjuster = IngredientAdjuster.new(ingredient, 1.3)
        result = adjuster.call

        expect(result[:amount]).to eq(1.3)
      end
    end
  end
end
