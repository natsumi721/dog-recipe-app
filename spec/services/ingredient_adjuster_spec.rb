require 'rails_helper'

RSpec.describe IngredientAdjuster do
  describe '#call' do
    context 'piece単位の場合' do
      it '0.3個(元の量1個 × 倍率0.3)は1個になる' do
        ingredient = { name: "卵", amount: 1, unit: "piece" }
        adjuster = IngredientAdjuster.new(ingredient, 0.3)
        result = adjuster.call

        expect(result[:amount]).to eq(1)
      end

      it '0.4個(元の量2個 × 倍率0.2)は1個になる' do
        ingredient = { name: "卵", amount: 2, unit: "piece" }
        adjuster = IngredientAdjuster.new(ingredient, 0.2)
        result = adjuster.call

        expect(result[:amount]).to eq(1)
      end

      it '1.3個(元の量1個 × 倍率1.3)は1個になる' do
        ingredient = { name: "卵", amount: 1, unit: "piece" }
        adjuster = IngredientAdjuster.new(ingredient, 1.3)
        result = adjuster.call

        expect(result[:amount]).to eq(1)
      end

      it '1.5個(元の量1個 × 倍率1.5)は2個になる' do
        ingredient = { name: "卵", amount: 1, unit: "piece" }
        adjuster = IngredientAdjuster.new(ingredient, 1.5)
        result = adjuster.call

        expect(result[:amount]).to eq(2)
      end

      it '1.8個(元の量1個 × 倍率1.8)は2個になる' do
        ingredient = { name: "卵", amount: 1, unit: "piece" }
        adjuster = IngredientAdjuster.new(ingredient, 1.8)
        result = adjuster.call

        expect(result[:amount]).to eq(2)
        expect(result[:unit]).to eq("個")
      end
    end

    context 'g単位の場合' do
      it '132.5g(元の量100g × 倍率1.325)は135gになる' do
        ingredient = { name: "鶏肉", amount: 100, unit: "g" }
        adjuster = IngredientAdjuster.new(ingredient, 1.325)
        result = adjuster.call

        expect(result[:amount]).to eq(135)
      end

      it '65g(元の量100g × 倍率0.65)は65gになる' do
        ingredient = { name: "鶏肉", amount: 100, unit: "g" }
        adjuster = IngredientAdjuster.new(ingredient, 0.65)
        result = adjuster.call

        expect(result[:amount]).to eq(65)
      end

      it '132.5g(元の量100g × 倍率1.325)は135gになる' do
        ingredient = { name: "鶏肉", amount: 100, unit: "g" }
        adjuster = IngredientAdjuster.new(ingredient, 1.325)
        result = adjuster.call

        expect(result[:amount]).to eq(135)
      end
    end

    context 'tsp単位の場合' do
      it '1.3tsp(元の量1tsp × 倍率1.3)は1.3tspになる' do
        ingredient = { name: "塩", amount: 1, unit: "tsp" }
        adjuster = IngredientAdjuster.new(ingredient, 1.3)
        result = adjuster.call

        expect(result[:amount]).to eq(1.3)
        expect(result[:unit]).to eq("小さじ")
      end

      it '0.65tsp(元の量1tsp × 倍率0.65)は0.7tspになる' do
        ingredient = { name: "塩", amount: 1, unit: "tsp" }
        adjuster = IngredientAdjuster.new(ingredient, 0.65)
        result = adjuster.call

        expect(result[:amount]).to eq(0.7)
      end

      it '1.325tsp(元の量1tsp × 倍率1.325)は1.3tspになる' do
        ingredient = { name: "塩", amount: 1, unit: "tsp" }
        adjuster = IngredientAdjuster.new(ingredient, 1.325)
        result = adjuster.call

        expect(result[:amount]).to eq(1.3)
      end
    end

    context 'tbsp単位の場合' do
      it '1.3tbsp(元の量1tbsp × 倍率1.3)は1.3tbspになる' do
        ingredient = { name: "醤油", amount: 1, unit: "tbsp" }
        adjuster = IngredientAdjuster.new(ingredient, 1.3)
        result = adjuster.call

        expect(result[:amount]).to eq(1.3)
      end

      it '0.65tbsp(元の量1tbsp × 倍率0.65)は0.7tbspになる' do
        ingredient = { name: "醤油", amount: 1, unit: "tbsp" }
        adjuster = IngredientAdjuster.new(ingredient, 0.65)
        result = adjuster.call

        expect(result[:amount]).to eq(0.7)
      end
    end

    context 'エッジケース' do
      it '倍率が0の場合、piece単位は1個になる' do
        ingredient = { name: "卵", amount: 1, unit: "piece" }
        adjuster = IngredientAdjuster.new(ingredient, 0)
        result = adjuster.call

        expect(result[:amount]).to eq(1)
        expect(result[:unit]).to eq("個")
      end

      it '倍率が0の場合、g単位は0gになる' do
        ingredient = { name: "鶏肉", amount: 100, unit: "g" }
        adjuster = IngredientAdjuster.new(ingredient, 0)
        result = adjuster.call

        expect(result[:amount]).to eq(0)
      end

      it '倍率が0の場合、tsp単位は0.0tspになる' do
        ingredient = { name: "塩", amount: 1, unit: "tsp" }
        adjuster = IngredientAdjuster.new(ingredient, 0)
        result = adjuster.call

        expect(result[:amount]).to eq(0.0)
      end

      it '倍率が非常に大きい場合でも計算できる' do
        ingredient = { name: "鶏肉", amount: 100, unit: "g" }
        adjuster = IngredientAdjuster.new(ingredient, 10)
        result = adjuster.call

        expect(result[:amount]).to eq(1000)
      end
    end

    context '単位が保持される' do
      it 'piece単位が保持される' do
        ingredient = { name: "卵", amount: 1, unit: "個" }
        adjuster = IngredientAdjuster.new(ingredient, 1.5)
        result = adjuster.call

        expect(result[:unit]).to eq("個")
      end

      it 'g単位が保持される' do
        ingredient = { name: "鶏肉", amount: 100, unit: "g" }
        adjuster = IngredientAdjuster.new(ingredient, 1.5)
        result = adjuster.call

        expect(result[:unit]).to eq("g")
      end

      it 'tsp単位が保持される' do
        ingredient = { name: "塩", amount: 1, unit: "小さじ" }
        adjuster = IngredientAdjuster.new(ingredient, 1.5)
        result = adjuster.call

        expect(result[:unit]).to eq("小さじ")
      end
    end

    context '名前が保持される' do
      it '材料名が保持される' do
        ingredient = { name: "卵", amount: 1, unit: "piece" }
        adjuster = IngredientAdjuster.new(ingredient, 1.5)
        result = adjuster.call

        expect(result[:name]).to eq("卵")
      end
    end

    context 'ハッシュ全体の構造' do
      it '正しいハッシュ構造を返す' do
        ingredient = { name: "卵", amount: 1, unit: "piece" }
        adjuster = IngredientAdjuster.new(ingredient, 1.5)
        result = adjuster.call

        expect(result).to eq({
          name: "卵",
          amount: 2,
          unit: "個"
        })
      end
    end

    context '境界値テスト' do
      context 'piece単位の丸め処理' do
        it '0.49個は1個になる' do
          ingredient = { name: "卵", amount: 1, unit: "個" }
          adjuster = IngredientAdjuster.new(ingredient, 0.49)
          result = adjuster.call

          expect(result[:amount]).to eq(1)
        end

        it '0.5個は1個になる' do
          ingredient = { name: "卵", amount: 1, unit: "個" }
          adjuster = IngredientAdjuster.new(ingredient, 0.5)
          result = adjuster.call

          expect(result[:amount]).to eq(1)
        end

        it '1.49個は1個になる' do
          ingredient = { name: "卵", amount: 1, unit: "piece" }
          adjuster = IngredientAdjuster.new(ingredient, 1.49)
          result = adjuster.call

          expect(result[:amount]).to eq(1)
        end

        it '1.5個は2個になる' do
          ingredient = { name: "卵", amount: 1, unit: "piece" }
          adjuster = IngredientAdjuster.new(ingredient, 1.5)
          result = adjuster.call

          expect(result[:amount]).to eq(2)
        end
      end

      context 'g単位の丸め処理' do
        it '130.4g(元の量100g × 倍率1.304)は130gになる' do
          ingredient = { name: "鶏肉", amount: 100, unit: "g" }
          adjuster = IngredientAdjuster.new(ingredient, 1.304)
          result = adjuster.call

          expect(result[:amount]).to eq(130)
        end

        it '130.5g(元の量100g × 倍率1.305)は131gになる' do
          ingredient = { name: "鶏肉", amount: 100, unit: "g" }
          adjuster = IngredientAdjuster.new(ingredient, 1.305)
          result = adjuster.call

          expect(result[:amount]).to eq(130)
        end
      end

      context 'tsp単位の丸め処理' do
        it '1.34tsp(元の量1tsp × 倍率1.34)は1.3tspになる' do
          ingredient = { name: "塩", amount: 1, unit: "tsp" }
          adjuster = IngredientAdjuster.new(ingredient, 1.34)
          result = adjuster.call

          expect(result[:amount]).to eq(1.3)
        end

        it '1.35tsp(元の量1tsp × 倍率1.35)は1.4tspになる' do
          ingredient = { name: "塩", amount: 1, unit: "tsp" }
          adjuster = IngredientAdjuster.new(ingredient, 1.35)
          result = adjuster.call

          expect(result[:amount]).to eq(1.4)
        end
      end
    end
  end
end
