class RecipesController < ApplicationController
    skip_before_action :require_login, only: [ :index, :show ]
    skip_before_action :check_dog_profile, only: [ :index, :show ]

    def index
       if params[:dog_id].present?
          dog = current_user.dogs.find(params[:dog_id])
          @recipes = dog.recommended_recipes

       elsif params[:age_stage].present? || session[:guest_dog].present?
          # 未ログインユーザーのフィルタリング条件から取得
          dog_data = session[:guest_dog] || {}

          @dog = Dog.new(
            age_stage: params[:age_stage] || dog_data["age_stage"],
            body_type: params[:body_type] || dog_data["body_type"],
            activity_level: params[:activity_level] || dog_data["activity_level"],
            allergies: params[:allergies] || dog_data["allergies"] || []  # ← セッションから取得
          )
          @recipes = @dog.recommended_recipes

       else
        @recipes = Recipe.limit(3)
       end
    end

    def show
        @recipe = Recipe.find(params[:id])
  # ログインしている場合のみブックマーク情報を取得
  if logged_in?
    # 🐶 dog_id が渡されている場合
    if params[:dog_id].present?
      @dog = current_user.dogs.find(params[:dog_id])
      @bookmark = current_user.bookmarks.find_by(recipe: @recipe, dog: @dog)
    else
      # 🐶 1頭だけの場合は自動で設定
      @dog = current_user.dogs.first
      @bookmark = current_user.bookmarks.find_by(recipe: @recipe, dog: @dog)
    end
  end
      @return_to = params[:return_to]
    end

    def bookmarks
    dogs = current_user.dogs

    # 🐶 1頭だけなら自動でその子のブックマークへ
    if params[:dog_id].blank? && dogs.count == 1
      return redirect_to bookmarks_recipes_path(dog_id: dogs.first.id)
    end

    # 🐶 dog選択後 or 1頭のみ
    if params[:dog_id].present?
      @dog = dogs.find(params[:dog_id])

      @bookmark_recipes = current_user.bookmarks
                                   .where(dog_id: @dog.id)
                                   .includes(:recipe)
                                   .map(&:recipe)

      # 🐶 bookmarks_list.html.erb を表示
      render :bookmarks_list
    else
      # 🐶 複数頭のときだけ選択画面
      @dogs = dogs

      # 🐶 bookmarks_select.html.erb を表示
      render :bookmarks_select
    end
  end

  def select_dog
    @dogs = current_user.dogs
  end
end
