class AddAllergyTagsToRecipes < ActiveRecord::Migration[7.2]
  def change
    add_column :recipes, :allergy_tags, :text
  end
end
