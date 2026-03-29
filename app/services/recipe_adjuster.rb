class RecipeAdjuster
  def initialize(recipe, dog)
    @recipe = recipe
    @dog = dog
  end

  def call
    apply_amount_adjustment
    @recipe
  end

  private

  def apply_amount_adjustment
    multiplier = 1.0

    # 年齢
    multiplier *= 1.2 if @dog.age_stage_puppy?
    multiplier *= 0.85 if @dog.age_stage_senior?

    # 体型
    multiplier *= 1.2 if @dog.body_type_thin?
    multiplier *= 0.9 if @dog.body_type_overweight?

    # 運動量
    multiplier *= 1.2 if @dog.activity_level_high?
    multiplier *= 0.9 if @dog.activity_level_low?

    @recipe.adjusted_multiplier = multiplier
  end
end
