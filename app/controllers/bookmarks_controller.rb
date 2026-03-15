class BookmarksController < ApplicationController
  def create
    @recipe = Recipe.find(params[:recipe_id])
    current_user.bookmarks.create(recipe: @recipe)
    redirect_to recipe_path(@recipe), notice: "ブックマークしました"
  end

  def destroy
    @bookmark = current_user.bookmarks.find(params[:id])
    @bookmark.destroy
    redirect_to bookmarks_recipes_path, notice: "ブックマークを解除しました"
  end
end
