class DogsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create, :complete ]
  def new
    @dog = Dog.new
  end

  def create
    @dog = current_user.dogs.build(dog_params)
   
    if @dog.save
      redirect_to complete_dog_path(@dog)
    else
      flash.now[:alert] = "情報の保存に失敗しました。入力内容を確認してください。"
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @dogs = current_user.dog
  end

    # 完了画面へリダイレクト
    def complete
      @dog = Dog.find(params[:id])
    end

  private

  def dog_params
    params.require(:dog).permit(
      :name,
      :size,
      :age_stage,
      :body_type,
      :activity_level,
      allergies: []
    )
  end
end
