class InfluencersController < ApplicationController
  before_action :require_influencer, only: [ :index ]
  layout "influencer"
  def index
    @user = Current.session.user
  end

  def profile
    @user = Current.session.user
  end
end
