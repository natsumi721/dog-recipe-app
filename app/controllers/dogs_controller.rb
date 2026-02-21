class DogsController < ApplicationController
  def new
    @dog = Dog.new
  end

  def create
    @dog = Dog.new(dog_params)
    @dog.user = User.first  # 仮に最初のユーザーを関連付ける。実際にはログインユーザーを使用するべき。

    if @dog.save
      redirect_to complete_dog_path(@dog)
    else
      flash.now[:alert] = "情報の保存に失敗しました。入力内容を確認してください。"
      render :new, status: :unprocessable_entity
    end
  end

    # 完了画面へリダイレクト
    def complete
      @dog = Dog.find(params[:id])
    end

  private

  def dog_params
    params.require(:dog).permit(:name, :size, :age_stage, :body_type, :activity_level, :allergies)
  end
end
