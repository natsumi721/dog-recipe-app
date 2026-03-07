class RecipesController < ApplicationController
    skip_before_action :require_login, only: [ :index, :show ]
    def index
       if params[:dog_id]
          dog = Dog.find(params[:dog_id])
          @recipes = dog.recommended_recipes
       else
        @recipes =Recipe.limit(3)
       end
    end

    def show
        @recipe = Recipe.find(params[:id])
    end
end
