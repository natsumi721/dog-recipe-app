class Admin::UsersController < ApplicationController
  def index
    @users_count = User.count
    @dogs_count = Dog.count

    @users = User.includes(:dogs).order(created_at: :desc)
  end
end
