class RecipesController < ApplicationController
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
