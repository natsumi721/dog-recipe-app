class PortionAdjuster
  SIZE_MULTIPLIER = {
    small: 0.7,
    medium: 1.0,
    large: 1.5
  }

  def initialize(recipe, dog)
    @recipe = recipe
    @dog = dog
  end

  def call
    multiplier = SIZE_MULTIPLIER[@dog.size.to_sym]
    @recipe.adjusted_multiplier *= multiplier
    @recipe
  end
end