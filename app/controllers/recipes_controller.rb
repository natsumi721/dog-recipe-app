class RecipesController < ApplicationController
    skip_before_action :require_login, only: [ :index, :show ]
    skip_before_action :check_dog_profile, only: [ :index, :show ]

    def index
       if params[:dog_id].present?
          dog = current_user.dogs.find(params[:dog_id])
          @recipes = dog.recommended_recipes

       elsif params[:age_stage].present?
          # 未ログインユーザーのフィルタリング条件から取得
          # 一時的なDogオブジェクトを作成してrecommended_recipesメソッドを利用
          @dog = Dog.new(
            age_stage: params[:age_stage],
            body_type: params[:body_type],
            activity_level: params[:activity_level],
            allergies: params[:allergies] || []
          )
          @recipes = @dog.recommended_recipes

       else
        @recipes = Recipe.limit(3)
       end
    end

    def show
        @recipe = Recipe.find(params[:id])
    end

    def select_dog
      @dogs = current_user.dogs
    end
end
