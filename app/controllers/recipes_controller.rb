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

  #  確認画面から戻るアクション
  def back_to_new
    # パラメータをセッションに保存
    session[:recipe_draft] = params[:recipe].to_unsafe_h
    redirect_to new_recipe_path
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

      #  ここで @recipe.ingredients_json に代入
      @recipe.ingredients_json = { "medium" => filtered }
    end

    #  全角数字を半角に変換
    normalize_ingredients!(@recipe)

    @recipe.status = "draft"

    #  バリデーションチェック
    if @recipe.valid?
      render :confirm
    else
      flash.now[:alert] = "入力内容を確認してください"
      render :new, status: :unprocessable_entity
    end
  end

  def create
    @recipe = current_user.recipes.build(recipe_params)
    @recipe.status = "draft"

    #  JSON文字列をパースして ingredients_json に代入
    if params[:recipe][:ingredients_json_string].present?
      @recipe.ingredients_json = JSON.parse(params[:recipe][:ingredients_json_string])
    end

    # 全角数字を半角に変換（JSON代入後に実行）
    normalize_ingredients!(@recipe)

    #  保存
    if @recipe.save
      redirect_to select_action_recipes_path, notice: "レシピを保存しました。管理者の承認後に公開されます。"
    else
      flash.now[:alert] = "レシピの保存に失敗しました。入力内容を確認してください。"
      render :new, status: :unprocessable_entity
    end
  end




  def index
    if params[:dog_id].present? && logged_in?
      @dog = current_user.dogs.find(params[:dog_id])
      @recipes = fetch_or_sample_recipes(@dog)

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
      @recipes = fetch_or_sample_recipes(@dog)

    else
      @recipes = Recipe.published.limit(5)
    end
  end

  def show
  @recipe = Recipe.find(params[:id])

  # ★ 戻り先を設定
  if params[:from] == "my_recipes"
    @return_to = select_action_recipes_path
  elsif params[:return_to].present?
    @return_to = params[:return_to]
  else
    @return_to = recipes_path
  end

  unless @recipe.published? || current_user&.admin? || @recipe.user == current_user
    redirect_to recipes_path, alert: "このレシピはまだ公開されていません"
    return
  end

  # OGP設定
  set_ogp

  # ★ from=my_recipes の場合は犬のサイズに調整しない
  if params[:from] == "my_recipes"
    # 投稿時の材料（medium）をそのまま表示
    if @recipe.json_format?
      @adjusted_ingredients = @recipe.ingredients_json["medium"] || []
    else
      @adjusted_ingredients = []
    end
    return
  end

  # ★ 管理者の場合は medium のレシピをそのまま表示
  if current_user&.admin?
    if @recipe.json_format?
      @adjusted_ingredients = @recipe.ingredients_json["medium"] || []
    else
      @adjusted_ingredients = []
    end
    return
  end

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
    @adjusted_ingredients = @recipe.adjusted_ingredients(@dog, @dog.size.to_sym, meals: 4)
  else
    @adjusted_ingredients = []
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

  #  全角数字を半角に変換するメソッド
  def normalize_ingredients!(recipe)
    return if recipe.ingredients_json.blank?

    # medium の配列を取得
    ingredients = recipe.ingredients_json["medium"]
    return if ingredients.blank?

    # 配列の各要素の amount を半角に変換
    ingredients.each do |ingredient|
      if ingredient["amount"].present?
        # 全角数字を半角に変換
        ingredient["amount"] = ingredient["amount"].to_s.tr("０-９", "0-9")
      end
    end

    # 変換後の値を再セット
    recipe.ingredients_json = { "medium" => ingredients }
  end


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
      allergy_tags: [],
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

  def fetch_or_sample_recipes(dog)
  # 上位20件をセッションに保存（初回のみ）
  unless session[:top_recipe_ids].present?
    top_recipes = dog.recommended_recipes # 上位20件を取得するメソッド
    session[:top_recipe_ids] = top_recipes.map(&:id)
  end

  # シャッフルボタンが押された場合は選択された5件をクリア
  if params[:shuffle] == "true"
    session[:selected_recipe_ids] = nil
  end

  # セッションに保存されたレシピIDがある場合はそれを使用
  if session[:selected_recipe_ids].present?
    Recipe.where(id: session[:selected_recipe_ids]).to_a
  else
    # セッションに保存された上位20件の中から5件をサンプリング
    top_recipe_ids = session[:top_recipe_ids]
    sampled_ids = top_recipe_ids.sample(5)

    # セッションに保存
    session[:selected_recipe_ids] = sampled_ids

    Recipe.where(id: sampled_ids).to_a
  end
end
end
