class LandingPagesController < ApplicationController
  # Allow unauthenticated access to specific actions
  allow_unauthenticated_access only: %i[index service support aboutus policy]

  # Set @user for all actions
  before_action :set_user

  def index
    # @user is already set by before_action
  end

  def service
  end

  def support
  end

  def aboutus
  end

  def policy
  end

  private

  def set_user
    @user = Current.session.user if authenticated?
  end
end
