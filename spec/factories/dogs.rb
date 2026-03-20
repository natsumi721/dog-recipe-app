FactoryBot.define do
  factory :dog do
    name { "ポチ" }
    size { :small }
    age_stage { :adult }
    body_type { :normal }
    activity_level { :medium }
    allergies { [] }
  end
end
