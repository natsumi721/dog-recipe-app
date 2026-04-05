require 'rails_helper'

RSpec.describe Dog, type: :model do
  it "有効な犬は保存できる" do
    dog = build(:dog)
    expect(dog).to be_valid
  end

  it "nameがないと無効" do
    dog = build(:dog, name: nil)
    expect(dog).to be_invalid
  end

  it "sizeがないと無効" do
    dog = build(:dog, size: nil)
    expect(dog).to be_invalid
  end

  it "age_stageがないと無効" do
    dog = build(:dog, age_stage: nil)
    expect(dog).to be_invalid
  end

  describe "#recommended_recipes" do
    it "条件に一致するレシピが返る" do
      dog = create(:dog, age_stage: :adult, body_type: :normal, activity_level: :medium)

      recipe = create(:recipe,
        age_stage: :adult,
        body_type: :normal,
        activity_level: :medium,
      )

      result = dog.recommended_recipes

      expect(result).to include(recipe)
    end

    it "アレルギー食材を含むレシピは除外される" do
      dog = create(:dog,
        age_stage: :adult,
        body_type: :normal,
        activity_level: :medium,
        size: :medium,
        allergies: [ "鶏肉" ]
      )

      safe_recipe = create(:recipe,
        ingredients_json: {
          "medium" => [
            { "name" => "魚", "amount" => 100, "unit" => "g" }
         ]
        }
      )

      ng_recipe = create(:recipe,
        ingredients_json: {
          "medium" => [
            { "name" => "鶏肉", "amount" => 100, "unit" => "g" }
          ]
        }
      )

  result = dog.recommended_recipes

  expect(result).to include(safe_recipe)
  expect(result).not_to include(ng_recipe)
end

    it "最大5件返す" do
      dog = create(:dog, age_stage: :adult, body_type: :normal, activity_level: :medium)

      create_list(:recipe, 6,
        age_stage: :adult,
        body_type: :normal,
        activity_level: :medium,
      )

      result = dog.recommended_recipes

      expect(result.length).to be <= 5
    end
  end

    it "ユーザーは複数の犬を登録できる" do
      user = create(:user)

      dog1 = create(:dog, user: user)
      dog2 = create(:dog, user: user)

      expect(user.dogs.count).to eq(2)
    end

   it "犬ごとに異なるレシピが返る" do
   user = create(:user)
  dog1 = create(:dog, user: user, age_stage: :puppy, body_type: :thin, activity_level: :low, size: :small)
  dog2 = create(:dog, user: user, age_stage: :adult, body_type: :normal, activity_level: :medium, size: :medium)

  recipe1 = create(:recipe, age_stage: :puppy, body_type: :thin, activity_level: :low)
  recipe2 = create(:recipe, age_stage: :adult, body_type: :normal, activity_level: :medium)

  dog1_recipes = dog1.recommended_recipes
  dog2_recipes = dog2.recommended_recipes

  # ✅ スコアが高いレシピが含まれることを確認
  expect(dog1_recipes).to include(recipe1)
  expect(dog2_recipes).to include(recipe2)
end
end
