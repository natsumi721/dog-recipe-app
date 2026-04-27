require 'rails_helper'

RSpec.describe Dog, type: :model do
  # バリデーションのテスト
  describe "バリデーション" do
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
  end

  # 画像添付のテスト
  describe "画像添付" do
    it "画像を添付できる" do
      dog = build(:dog)

      file = fixture_file_upload(
        Rails.root.join("spec/fixtures/files/test_image.png"),
        "image/png"
      )

      dog.avatar.attach(file)

      expect(dog.avatar).to be_attached
    end

    it "複数の犬がそれぞれ画像を持てる" do
      user = create(:user)
      dogs = create_list(:dog, 2, user: user)

      dogs.each_with_index do |dog, i|
        dog.avatar.attach(
          io: File.open(Rails.root.join("spec/fixtures/files/test_dog.jpg")),
          filename: "dog#{i}.jpg",
          content_type: "image/jpeg"
        )
      end

      expect(dogs.all? { |d| d.avatar.attached? }).to be true
    end

    it "webp形式で保存される" do
      dog = build(:dog)

      file = fixture_file_upload(
        Rails.root.join('spec/fixtures/files/test_image.png'),
        'image/png'
      )

      processed = ImageProcessor.process(file)

      dog.avatar.attach(
        io: processed,
        filename: "processed.webp",
        content_type: "image/webp"
      )

      dog.save!

      expect(dog.avatar).to be_attached
      expect(dog.avatar.blob.content_type).to eq("image/webp")
    end
  end

  # アレルギー情報のテスト
  describe "allergies（アレルギー情報）" do
    it "配列として保存される" do
      dog = create(:dog, allergies: [ "牛肉", "鶏肉" ])

      # データベースから再取得
      dog.reload

      expect(dog.allergies).to eq([ "牛肉", "鶏肉" ])
      expect(dog.allergies.class).to eq(Array)
      expect(dog.allergies_i18n).to eq("牛肉, 鶏肉")
    end

    it "allergies_i18nは空の場合に'なし'を返す" do
      dog = create(:dog, allergies: [])

      expect(dog.allergies_i18n).to eq("なし")
    end

    it "allergiesがnilの場合も'なし'を返す" do
      dog = create(:dog, allergies: nil)

      expect(dog.allergies_i18n).to eq("なし")
    end
  end

  # 推奨レシピのテスト
  describe "#recommended_recipes" do
    it "条件に一致するレシピが返る" do
      dog = create(:dog, age_stage: :adult, body_type: :normal, activity_level: :medium, size: :medium)

    recipe = create(:recipe,
      age_stage: :adult,
      body_type: :normal,
      activity_level: :medium,
      ingredients_json: {
        "medium" => [
          { "name" => "魚", "amount" => 100, "unit" => "g" }
        ]
      }
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
            { "name" => "魚", "amount" => 100, "unit" => "g", "tags" => [ "fish" ] }
          ]
        }
      )

      ng_recipe = create(:recipe,
        ingredients_json: {
          "medium" => [
            { "name" => "鶏肉", "amount" => 100, "unit" => "g", "tags" => [ "chicken" ] }
          ]
        }
      )

      result = dog.recommended_recipes

      expect(result).to include(safe_recipe)
      expect(result).not_to include(ng_recipe)
    end

    it "最大20件返す" do
      dog = create(:dog, age_stage: :adult, body_type: :normal, activity_level: :medium, size: :medium)

    create_list(:recipe, 25,
      age_stage: :adult,
      body_type: :normal,
      activity_level: :medium,
      ingredients_json: {
        "medium" => [
          { "name" => "魚", "amount" => 100, "unit" => "g" }
        ]
      }
    )

    result = dog.recommended_recipes

    expect(result.length).to be <= 20
  end
  end

  # ユーザーとの関連のテスト
  describe "ユーザーとの関連" do
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

      # スコアが高いレシピが含まれることを確認
      expect(dog1_recipes).to include(recipe1)
      expect(dog2_recipes).to include(recipe2)
    end
  end
end
