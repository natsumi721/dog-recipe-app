class StaticPagesController < ApplicationController
  skip_before_action :require_login, only: [ :privacy_policy, :terms_of_service ]

  def privacy_policy
  end

  def terms_of_service
  end
end
