class RecipesController < ApplicationController
    def index
        if params[:dog_id]
            dog = Dog.find(params[:dog_id])

            @recipes = Recipe.where(
                age_stage: dog.age_stage,
                body_type: dog.body_type,
                activity_level: dog.activity_level
            ).order("RANDOM()").limit(3)

        else
            @recipes = Recipe.all
        end
    end 

    def show
        @recipe = Recipe.find(params[:id])
    end
end
