class Dog < ApplicationRecord
  belongs_to :user, optional: true

  enum size: { small: 0, medium: 1, large: 2 }, _prefix: true
  enum age_stage: { puppy: 0, adult: 1, senior: 2 }, _prefix: true
  enum body_type: { thin: 0, normal: 1, overweight: 2 }, _prefix: true
  enum activity_level: { low: 0, medium: 1, high: 2 }, _prefix: true

  validates :name, presence: true
  validates :size, presence: true
  validates :age_stage, presence: true
  validates :body_type, presence: true
  validates :activity_level, presence: true
end
