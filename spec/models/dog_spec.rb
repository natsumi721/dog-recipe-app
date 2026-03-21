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
        activity_level: :medium
      )

      result = dog.recommended_recipes

      expect(result).to include(recipe)
    end

    it "条件に一致しないレシピは含まれない" do
      dog = create(:dog, age_stage: :adult, body_type: :normal, activity_level: :medium)

        ng_recipe = create(:recipe,
          age_stage: :puppy, # ← 不一致
          body_type: :normal,
          activity_level: :medium
        )

      result = dog.recommended_recipes

      expect(result).not_to include(ng_recipe)
    end

    it "アレルギー食材を含むレシピは除外される" do
      dog = create(:dog,
        age_stage: :adult,
        body_type: :normal,
        activity_level: :medium,
        allergies: [ "鶏肉" ]
      )

      safe_recipe = create(:recipe,
        ingredients: "魚"
      )

      ng_recipe = create(:recipe,
        ingredients: "鶏肉"
      )

      result = dog.recommended_recipes

      expect(result).to include(safe_recipe)
      expect(result).not_to include(ng_recipe)
    end

    it "最大3件返す" do
      dog = create(:dog, age_stage: :adult, body_type: :normal, activity_level: :medium)

      create_list(:recipe, 5,
        age_stage: :adult,
        body_type: :normal,
        activity_level: :medium
      )

      result = dog.recommended_recipes

      expect(result.length).to be <= 3
    end
  end

  it "ユーザーは複数の犬を登録できる" do
  user = create(:user)

  dog1 = create(:dog, user: user)
  dog2 = create(:dog, user: user)

  expect(user.dogs.count).to eq(2)
end

  it "犬ごとに異なるレシピが返る" do
  dog1 = create(:dog, age_stage: :adult, body_type: :normal, activity_level: :medium)
  dog2 = create(:dog, age_stage: :puppy, body_type: :thin, activity_level: :low)

  recipe1 = create(:recipe,
    age_stage: :adult,
    body_type: :normal,
    activity_level: :medium
  )

  recipe2 = create(:recipe,
    age_stage: :puppy,
    body_type: :thin,
    activity_level: :low
  )

  expect(dog1.recommended_recipes).to include(recipe1)
  expect(dog1.recommended_recipes).not_to include(recipe2)

  expect(dog2.recommended_recipes).to include(recipe2)
  expect(dog2.recommended_recipes).not_to include(recipe1)
end
end
