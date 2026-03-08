class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :require_login
  before_action :check_dog_profile, if: :current_user, unless: :skip_dog_check?

  def check_dog_profile
    return unless current_user.dogs.empty?
    return if controller_name.in?(%w[dogs sessions])

    redirect_to new_dog_path
  end
  
  def skip_dog_check?
    controller_name == "sessions" && action_name == "destroy"
  end
end
