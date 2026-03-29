class AddBaseIngredientsToRecipes < ActiveRecord::Migration[7.2]
  def change
    add_column :recipes, :base_ingredients, :json
  end
end
