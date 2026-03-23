class FixBookmarksUniqueIndex < ActiveRecord::Migration[7.2]
  def change
    # 既存のインデックスを削除
    remove_index :bookmarks, name: "index_bookmarks_on_user_id_and_recipe_id"
    
    # 新しいインデックスを追加（user_id, recipe_id, dog_id の組み合わせで一意）
    add_index :bookmarks, [ :user_id, :recipe_id, :dog_id ], unique: true
  end
end
