class Admin::RecipesController < ApplicationController
    before_action :require_login
    before_action :require_admin

    def index
      @recipes = Recipe.draft
    end

    def show
      @recipe = Recipe.find(params[:id])
    end

    def update
      @recipe = Recipe.find(params[:id])

      if params[:commit] == "承認する"
        @recipe.published!
      elsif params[:commit] == "却下する"
        @recipe.rejected!
      end

      redirect_to admin_recipes_path, notice: "更新しました"
    end

    private

    def require_admin
      redirect_to root_path unless current_user.admin?
    end
end
