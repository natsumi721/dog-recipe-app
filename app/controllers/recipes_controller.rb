class RecipesController < ApplicationController
  skip_before_action :require_login, only: [ :index, :show ]
  skip_before_action :check_dog_profile, only: [ :index, :show ]

  def new
    @recipe = Recipe.new
  end

  def confirm
    @recipe = current_user.recipes.build(recipe_params)
    @recipe.status = "draft"
  end

  def create
    @recipe = current_user.recipes.build(recipe_params)
    @recipe.status = "draft"

    if @recipe.save
      redirect_to recipes_path, notice: "レシピを保存しました。管理者の承認後に公開されます。"
    else
      flash.now[:alert] = "レシピの保存に失敗しました。入力内容を確認してください。"
      render :new, status: :unprocessable_entity
    end
  end

  def index
    if params[:dog_id].present? && logged_in?
      @dog = current_user.dogs.find(params[:dog_id])
      @recipes = @dog.recommended_recipes

    elsif params[:age_stage].present? || session[:guest_dog].present?
      # 未ログインユーザーのフィルタリング条件から取得
      dog_data = session[:guest_dog] || {}

      @dog = Dog.new(
        age_stage: params[:age_stage] || dog_data["age_stage"],
        body_type: params[:body_type] || dog_data["body_type"],
        activity_level: params[:activity_level] || dog_data["activity_level"],
        size: params[:size] || dog_data["size"],
        allergies: params[:allergies] || dog_data["allergies"] || []
      )
      @recipes = @dog.recommended_recipes
      @dog = current_user.dogs.first if logged_in?
    else
      @recipes = Recipe.published.limit(5)
    end
  end

  def show
    @recipe = Recipe.find(params[:id])
    @return_to = params[:return_to]

    # OGP設定
    set_ogp

    # ログインしていない場合は早期リターン
    return unless logged_in?

    # 犬の情報を取得
    @dog = if params[:dog_id].present?
             current_user.dogs.find(params[:dog_id])
    else
             current_user.dogs.first
    end


    # ブックマーク情報を取得
    @bookmark = current_user.bookmarks.find_by(recipe: @recipe, dog: @dog) if @dog.present?

    # JSON形式のレシピの場合、各サイズ用に調整された材料を取得
    if @recipe.json_format? && @dog.present?
      @adjusted_ingredients = @recipe.adjusted_ingredients(@dog, @dog.size.to_sym)
    else
      @adjusted_ingredients = []  # 空の配列で初期化
    end
  end

  def bookmarks
    dogs = current_user.dogs

    # 1頭だけなら自動でその子のブックマークへ
    if params[:dog_id].blank? && dogs.count == 1
      return redirect_to bookmarks_recipes_path(dog_id: dogs.first.id)
    end

    # dog選択後 or 1頭のみ
    if params[:dog_id].present?
      @dog = dogs.find(params[:dog_id])

      @bookmark_recipes = current_user.bookmarks
                                      .where(dog_id: @dog.id)
                                      .includes(:recipe)
                                      .map(&:recipe)

      # bookmarks_list.html.erb を表示
      render :bookmarks_list
    else
      # 複数頭のときだけ選択画面
      @dogs = dogs

      # bookmarks_select.html.erb を表示
      render :bookmarks_select
    end
  end

  def select_dog
    @dogs = current_user.dogs
  end

  private

  def recipe_params
    params.require(:recipe).permit(
      :name,
      :description,
      :instructions,
      :nutrition_note,
      :nutrition_note,
      :age_stage,
      :body_type,
      :activity_level,
      :size,
      :allergies,
      ingredients_json: {}
    )
  end

  def set_ogp
    set_meta_tags(
      title: @recipe.name,
      description: @recipe.nutrition_note,
      og: {
        title: @recipe.name,
        description: @recipe.nutrition_note,
        image: view_context.image_url("ogp.png")
      }
    )
  end
end
