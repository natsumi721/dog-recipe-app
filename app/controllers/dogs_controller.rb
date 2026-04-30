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

      if processed
           @dog.avatar.attach(
             io: processed,
             filename: "processed.webp",
             content_type: "image/webp"
           )
      end
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

  # ① 属性を先にセット（DBにはまだ保存しない）
  @dog.assign_attributes(dog_params_without_avatar)

  # ② 削除チェック（※新規画像がないときだけ）
  if params[:dog][:remove_avatar] == "1" && params[:dog][:avatar].blank?
    @dog.avatar.purge
  end

  # ③ 画像処理
  if params[:dog][:avatar].present?
    Rails.logger.info "ImageProcessor: Starting image processing for update"

    processed = ImageProcessor.process(params[:dog][:avatar])

    if processed

      @dog.avatar.attach(io: processed,
    filename: "processed.webp",
    content_type: "image/webp")

      Rails.logger.info "Avatar attached successfully"
    else
      Rails.logger.error "ImageProcessor failed, fallback original"
      @dog.avatar.attach(params[:dog][:avatar])
    end
  end

  # ④ 最後に保存
  if @dog.save
    redirect_to dashboard_path, notice: "愛犬情報を更新しました"
  else

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
    # 画像以外のパラメータを許可
    permitted = params.require(:dog).permit(
      :name,
      :size,
      :age_stage,
      :body_type,
      :activity_level,
      allergies: []
    )

  # ✅ allergies が nil の場合は空配列にする
  permitted[:allergies] = Array(permitted[:allergies]).reject(&:blank?)

  permitted
  end

  def logged_in?
    current_user.present?
  end
end
