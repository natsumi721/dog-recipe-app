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

  attribute :allergies, :string, array: true, default: []

  def recommended_recipes
  recipes = Recipe.where(
    age_stage: age_stage,
    body_type: body_type,
    activity_level: activity_level
  )

  return recipes.order("RANDOM()").limit(3) unless allergies.present?

    recipes = recipes.to_a.reject do |recipe|
      allergies.any? do |a|
        base = a.gsub("肉", "")
        recipe.ingredients.include?(base)
      end
    end

    recipes.sample(3)
  end
end
