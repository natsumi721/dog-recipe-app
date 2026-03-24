class SetDefaultStatusToExistingRecipes < ActiveRecord::Migration[7.2]
  def up
    Recipe.update_all(status: 1) # publishedにする
  end

  def down
    Recipe.update_all(status: 0) # 戻すならdraft
  end
end
