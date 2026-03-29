class AddIngredientsJsonToRecipes < ActiveRecord::Migration[7.2]
  def change
    add_column :recipes, :ingredients_json, :json
  end
end
