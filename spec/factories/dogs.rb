FactoryBot.define do
  factory :dog do
    sequence(:name) { |n| "ポチ#{n}" }
    size { :small }
    age_stage { :adult }
    body_type { :normal }
    activity_level { :medium }
    allergies { [] }
  end
end
