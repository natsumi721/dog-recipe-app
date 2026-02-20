class DogsController < ApplicationController
  def new
    @dog = Dog.new
  end

  def create
    @dog = Dog.new(dog_params)
    @dog.user = User.first  # 仮に最初のユーザーを関連付ける。実際にはログインユーザーを使用するべき。

    if @dog.save
      redirect_to root_path, notice: "情報登録完了！！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def dog_params
    params.require(:dog).permit(:name, :size, :age_stage, :body_type, :activity_level, :allergies)
  end
end
