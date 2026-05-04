class Admin::RecipesController < Admin::BaseController  # ← ここを変更
  before_action :set_recipe, only: [ :show, :edit,:update ]

  # 下書きレシピ一覧
  def index
    @recipes = Recipe.draft
  end

  # 承認済みレシピ一覧
  def published
    @recipes = Recipe.published.order(updated_at: :desc)
  end

  # 却下レシピ一覧
  def rejected
    @recipes = Recipe.rejected.order(updated_at: :desc)
  end


  def show
  end

  def edit
  end

  def update

    case params[:commit]
    when I18n.t("admin.recipes.actions.approve")
      # 下書き または 却下済み の場合のみ承認可能
      if @recipe.draft? || @recipe.rejected?
        @recipe.published!
        redirect_to published_admin_recipes_path, notice: "承認しました"
      else
        redirect_to admin_recipes_path, alert: "このレシピは既に承認されています"
      end

    when I18n.t("admin.recipes.actions.reject")
      # 下書き または 承認済み の場合のみ却下可能
      if @recipe.draft? || @recipe.published?
        @recipe.rejected!
        redirect_to rejected_admin_recipes_path, notice: "却下しました"
      else
        redirect_to admin_recipes_path, alert: "このレシピは既に却下されています"
      end

    else
     if @recipe.update(recipe_params)
        redirect_to admin_recipe_path(@recipe), notice: "レシピを更新しました"
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end


  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(
      :name,
      :description,
      :image,
      :remove_image,
      :ingredients_json,
      allergy_tags: []
    )
  end

  def require_admin
    redirect_to root_path, alert: "管理者権限が必要です" unless current_user&.admin?
  end
end