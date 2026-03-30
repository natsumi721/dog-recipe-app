FactoryBot.define do
  factory :recipe do
    sequence(:name) { |n| "テストレシピ#{n}" }
    description { "テスト用の説明" }
    age_stage { :adult }
    body_type { :normal }
    activity_level { :medium }
    ingredients { "鶏肉" }
    instructions { "焼く" }
    nutrition_note { "栄養あり" }
    status { :published }
  end
end
