class HomesController < ApplicationController
    skip_before_action :require_login, only: [:top]
    def top
    end
end
