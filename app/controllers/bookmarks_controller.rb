class BookmarksController < ApplicationController
  def create
    recipe = Recipe.find(params[:recipe_id])
    
    # 🐶 dog_id を取得
    dog = if params[:dog_id].present?
            current_user.dogs.find(params[:dog_id])
          else
            # 1頭だけの場合は自動で設定
            current_user.dogs.first
          end
    
    # 🐶 dog_id を保存
    current_user.bookmarks.create(recipe: recipe, dog: dog)
    
    # 🔙 元のページに戻る
    redirect_to params[:return_to] || recipes_path, success: t('.success')
  end

  def destroy
    bookmark = current_user.bookmarks.find(params[:id])
    bookmark.destroy!
    
    # 🔙 元のページに戻る
    redirect_to params[:return_to] || recipes_path, success: t('.success')
  end
end