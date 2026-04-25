class RecipesController < ApplicationController
  skip_before_action :require_login, only: [ :index, :show ]
  skip_before_action :check_dog_profile, only: [ :index, :show ]

  def new
    @recipe = Recipe.new

    # ★ セッションから入力内容を復元
    if session[:recipe_draft].present?
      draft = session[:recipe_draft]
      @recipe.assign_attributes(draft.except("ingredients_json"))
      @recipe.ingredients_json = draft["ingredients_json"]
      session.delete(:recipe_draft)  # 復元後はセッションをクリア
    end
  end

  def confirm
  @recipe = current_user.recipes.build(recipe_params)

  # ingredients_json を正規化
  if recipe_params[:ingredients_json].present? && recipe_params[:ingredients_json]["medium"].present?
    medium_ingredients = recipe_params[:ingredients_json]["medium"]

    # 正規化処理
    normalized = if medium_ingredients.is_a?(Hash)
      # ハッシュ形式の場合は配列に変換
      medium_ingredients.values.map do |ingredient|
        {
          "name" => ingredient["name"],
          "amount" => ingredient["amount"],
          "unit" => ingredient["unit"]
        }
      end
    elsif medium_ingredients.is_a?(Array)
      # すでに配列形式ならそのまま
      medium_ingredients.map do |ingredient|
        {
          "name" => ingredient["name"],
          "amount" => ingredient["amount"],
          "unit" => ingredient["unit"]
        }
      end
    else
      # それ以外の場合は空配列
      []
    end

    # 空の材料を除外
    filtered = normalized.reject do |i|
      i["name"].blank? || i["amount"].blank?
    end

    # ★ ここで @recipe.ingredients_json に代入
    @recipe.ingredients_json = { "medium" => filtered }
  end

  @recipe.status = "draft"

  # バリデーションチェック
  unless @recipe.valid?
    flash.now[:alert] = "入力内容を確認してください"
    render :new, status: :unprocessable_entity
  end
end

  def create
  @recipe = current_user.recipes.build(recipe_params)
  @recipe.status = "draft"

  # ★ JSON文字列をパースして ingredients_json に代入
  if params[:recipe][:ingredients_json_string].present?
    @recipe.ingredients_json = JSON.parse(params[:recipe][:ingredients_json_string])
  end

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
      
    else
      @recipes = Recipe.published.limit(5)
    end
  end

  def show
    @recipe = Recipe.find(params[:id])
    @return_to = params[:return_to]

    unless @recipe.published? || current_user&.admin? || @recipe.user == current_user
      redirect_to recipes_path, alert: "このレシピはまだ公開されていません"
      return
    end

    # OGP設定
    set_ogp

    # ログインユーザーの場合
    if logged_in?
    # 犬の情報を取得
      @dog = if params[:dog_id].present?
             current_user.dogs.find(params[:dog_id])
           else
             current_user.dogs.first
           end

    # ブックマーク情報を取得
    @bookmark = current_user.bookmarks.find_by(recipe: @recipe, dog: @dog) if @dog.present?

    else
      # ゲストユーザーの場合、セッションから犬情報を取得
      if session[:guest_dog].present?
        @dog = Dog.new(session[:guest_dog])
      end
    end

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

  def my_recipes
    @recipes = current_user.recipes.order(created_at: :desc)
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
      ingredients_json: {
        medium: [ :name, :amount, :unit ]
      }
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
