class CreateDogs < ActiveRecord::Migration[7.2]
  def change
    create_table :dogs do |t|
      t.string :name
      t.integer :size
      t.integer :age_stage
      t.integer :weight
      t.integer :body_type
      t.integer :activity_level
      t.text :allergies
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
