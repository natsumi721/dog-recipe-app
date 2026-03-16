class BookmarksController < ApplicationController
  def create
    @recipe = Recipe.find(params[:recipe_id])
    current_user.bookmarks.create(recipe: @recipe)
    redirect_to params[:return_to] || recipe_path(@recipe), notice: "ブックマークしました"
  end

  def destroy
    @bookmark = current_user.bookmarks.find(params[:id])
    recipe = @bookmark.recipe
    @bookmark.destroy
    redirect_to params[:return_to] || recipe_path(recipe), notice: "ブックマークを解除しました", status: :see_other
  end
end