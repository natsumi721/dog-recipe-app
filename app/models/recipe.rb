class Recipe < ApplicationRecord
  # enum :size, { small: 0, medium: 1, large: 2 }, prefix: true
  enum :age_stage, { puppy: 0, adult: 1, senior: 2 }, prefix: true
  enum :body_type, { thin: 0, normal: 1, overweight: 2 }, prefix: true
  enum :activity_level, { low: 0, medium: 1, high: 2 }, prefix: true

  include EnumI18n
  # enum の日本語化を有効にする
  enum_i18n :size
  enum_i18n :age_stage
  enum_i18n :body_type
  enum_i18n :activity_level


  validates :name, presence: true
end
