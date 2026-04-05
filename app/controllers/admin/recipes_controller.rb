class Admin::RecipesController < ApplicationController
    before_action :require_login
    before_action :require_admin
    before_action :set_recipe, only: [ :show, :update ]

    # 下書きレシピ一覧
    def index
      @recipes = Recipe.draft
    end

    # 承認済みレシピ一覧
    def published
      @recipes = Recipe.published
    end

    def show
    end

    def update
      if params[:commit] == I18n.t("admin.recipes.actions.approve")
        @recipe.published!
        redirect_to published_admin_recipes_path, notice: "承認済みに移動しました"
      elsif params[:commit] == I18n.t("admin.recipes.actions.reject")
        redirect_to admin_recipes_path, notice: "却下されました"
      else
        redirect_to admin_recipes_path, alert: "不正な操作です"
      end
    end

    private

    def set_recipe
       @recipe = Recipe.find(params[:id])
    end

    def require_admin
      redirect_to root_path unless current_user.admin?
    end
end
