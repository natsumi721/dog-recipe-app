class DogsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create, :complete ]
  before_action :set_dog, only: [ :edit, :update, :destroy ]

  def new
    @dog = Dog.new
  end

  def create
    # ログインしているかどうかで処理を分岐
    if logged_in?
      # ログインユーザーの場合、DBに保存
      @dog = current_user.dogs.build(dog_params.except(:avatar))

      if params[:dog][:avatar].present?
        processed = ImageProcessor.process(params[:dog][:avatar])
        @dog.avatar.attach(processed) if processed
      end

      if @dog.save
        redirect_to complete_dog_path(@dog), notice: "愛犬情報を登録しました!"
      else
        flash.now[:alert] = "情報の保存に失敗しました。入力内容を確認してください。"
        render :new, status: :unprocessable_entity
      end
    else
      # ゲストユーザーの場合、セッションに保存
      @dog = Dog.new(dog_params)

      if @dog.valid?
        session[:guest_dog] = dog_params.to_h
        # 完了ページへリダイレクト(guest=trueをパラメータで渡す)
        redirect_to complete_guest_dogs_path
      else
        flash.now[:alert] = "情報の保存に失敗しました。入力内容を確認してください。"
        render :new, status: :unprocessable_entity
      end
    end
  end

  # 完了ページ(ログインユーザーとゲストユーザー共通)
  def complete
    if logged_in?
      # ログインユーザーの場合、DBから取得
      @dog = current_user.dogs.find(params[:id])
    else
      # ゲストユーザーの場合、セッションから取得
      if session[:guest_dog].present?
        @dog = Dog.new(session[:guest_dog])
      else
        redirect_to root_path, alert: "犬情報が見つかりませんでした"
      end
    end
  end

  def index
    @dogs = current_user.dogs
  end

  def select_dog
    @dogs = current_user.dogs
  end

  def edit
  end

 def update
  @dog = current_user.dogs.find(params[:id])

  # 画像削除のチェックボックスがONの場合、画像を削除
  if params[:dog][:remove_avatar] == "1"
    @dog.avatar.purge
  end

  # ✅ 画像処理を先に行うが、添付はしない
  processed_image = nil
  if params[:dog][:avatar].present?
    Rails.logger.info "ImageProcessor: Starting image processing for update"
    processed_image = ImageProcessor.process(params[:dog][:avatar])
    
    if processed_image
      Rails.logger.info "ImageProcessor: Image processed successfully"
    else
      Rails.logger.error "ImageProcessor: Failed to process image"
      # 処理に失敗した場合は元の画像を使う
      processed_image = params[:dog][:avatar]
    end
  end

  # その他の属性を更新
  if @dog.update(dog_params_without_avatar)
    # ✅ 更新が成功した後に画像を添付
    if processed_image
      @dog.avatar.attach(processed_image)
      Rails.logger.info "Avatar attached successfully after update"
    end
    
    redirect_to dashboard_path, notice: "愛犬情報を更新しました"
  else
    # ✅ 更新が失敗した場合は画像を添付しない
    flash.now[:alert] = "情報の更新に失敗しました。入力内容を確認してください。"
    render :edit, status: :unprocessable_entity
  end
end


  def destroy
    if @dog.destroy
      redirect_to dogs_path, notice: t("defaults.flash_message.deleted", item: "愛犬"), status: :see_other
    else
      redirect_to dogs_path, alert: t("defaults.flash_message.not_deleted", item: "愛犬"), status: :see_other
    end
  end

  private

  def set_dog
    @dog = current_user.dogs.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to dashboard_path, alert: "愛犬が見つかりませんでした"
  end

  def dog_params
    permitted = params.require(:dog).permit(
      :name,
      :size,
      :age_stage,
      :body_type,
      :activity_level,
      :avatar,
      allergies: []
    )

     permitted[:allergies] = Array(permitted[:allergies]).reject(&:blank?)

     permitted
  end

  def dog_params_without_avatar
    # 🔥 画像以外のパラメータを許可
    params.require(:dog).permit(
      :name,
      :size,
      :age_stage,
      :body_type,
      :activity_level,
      allergies: []
    )
  end

  def logged_in?
    current_user.present?
  end
end
