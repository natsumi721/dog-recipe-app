class DogsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create, :complete ]
  before_action :set_dog, only: [:edit, :update, :destroy]
  
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
    @dogs = current_user.dogs
  end
  
  # 愛犬選択画面（レシピ用）★
  def select_dog
    @dogs = current_user.dogs
  end

  def edit
  
  end

  def update
    if @dog.update(dog_params)
      redirect_to complete_dog_path(@dog), notice: "愛犬情報を更新しました"
    else
      flash.now[:alert] = "情報の更新に失敗しました。入力内容を確認してください。"
      render :edit, status: :unprocessable_entity
    end
  end

    # 完了画面へリダイレクト
    def complete
      @dog = Dog.find(params[:id])
    end

  private

  def set_dog
    @dog = current_user.dogs.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "愛犬が見つかりませんでした"
  end



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
