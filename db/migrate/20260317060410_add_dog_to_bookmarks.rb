class AddDogToBookmarks < ActiveRecord::Migration[7.2]
  def change
    add_reference :bookmarks, :dog, null: true, foreign_key: true
  end
end
