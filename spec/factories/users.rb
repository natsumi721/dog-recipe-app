FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "テストユーザー#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "password12345" }
    password_confirmation { "password12345" }
    nickname { "テストニックネーム" }
  end
end
