class HomesController < ApplicationController
    skip_before_action :require_login, only: [ :top ]
    skip_before_action :check_dog_profile, only: [:top]

    def top
    end
end
