class CreateRecipes < ActiveRecord::Migration[7.2]
  def change
    create_table :recipes do |t|
      t.string :name
      t.text :description
      t.integer :life_stage
      t.integer :body_type
      t.integer :activity_level
      t.text :ingredients
      t.text :instructions
      t.text :nutrition_note

      t.timestamps
    end
  end
end
