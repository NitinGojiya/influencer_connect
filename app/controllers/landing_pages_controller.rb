class LandingPagesController < ApplicationController
    allow_unauthenticated_access only: %i[ index ]
  def index
     @user = Current.session.user if authenticated?
  end
end
