class Admin::RecipesController < Admin::BaseController  # ← ここを変更
  before_action :set_recipe, only: [ :show, :update ]

  # 下書きレシピ一覧
  def index
    @recipes = Recipe.draft
  end

  # 承認済みレシピ一覧
  def published
    @recipes = Recipe.published.order(updated_at: :desc)
  end

  def show
  end

  def update
  # 下書き状態のレシピのみ更新可能にする
  unless @recipe.draft?
    redirect_to admin_recipes_path, alert: "このレシピは既に処理されています"
    return
  end

    case params[:commit]
    when I18n.t("admin.recipes.actions.approve")
      @recipe.published!
      redirect_to published_admin_recipes_path, notice: "承認済みに移動しました"

    when I18n.t("admin.recipes.actions.reject")
      @recipe.rejected!
      redirect_to admin_recipes_path, notice: "却下しました"

    else
      redirect_to admin_recipes_path, alert: "不正な操作です"
    end
  end

  # 却下レシピ一覧
  def rejected
    @recipes = Recipe.rejected.order(updated_at: :desc)
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end
end
