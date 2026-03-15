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
        @bookmark = current_user.bookmarks.find_by(recipe: @recipe)
      end
    end

    def bookmarks
      @bookmark_recipes = current_user.bookmark_recipes.includes(:user).order(created_at: :desc)
    end

    def select_dog
      @dogs = current_user.dogs
    end

    def recommended_recipes
      recipes = Recipe.where(
        age_stage: age_stage,
        body_type: body_type,
        activity_level: activity_level
      )

      return recipes.order("RANDOM()").limit(3) unless allergies.present?

      recipes = recipes.to_a.reject do |recipe|
        allergies.any? do |a|
       base = a.gsub("肉", "")
      recipe.ingredients.include?(base)
      end
    end

      recipes.sample(3)
  end
end
