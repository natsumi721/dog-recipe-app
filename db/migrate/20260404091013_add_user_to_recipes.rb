class AddUserToRecipes < ActiveRecord::Migration[7.2]
  def change
    add_reference :recipes, :user, foreign_key: true, null: true
  end
end
