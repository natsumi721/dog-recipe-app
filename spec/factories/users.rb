FactoryBot.define do
  factory :user do
    sequence(:first_name) { |n| "太郎#{n}" }
    sequence(:last_name) { |n| "田中#{n}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "password12345" }
    password_confirmation { "password12345" }
    nickname { "テストニックネーム" }
  end
end
