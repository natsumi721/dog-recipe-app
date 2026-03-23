FactoryBot.define do
  factory :bookmark do
    association :user
    association :dog
    association :recipe
  end
end
