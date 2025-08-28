class InfluencersController < ApplicationController
  before_action :require_influencer, only: [ :index, :profile ]
  layout "influencer"
  def index
    @user = Current.session.user
    @campaigns = Campaign.all
  end

  def profile
    @user = Current.session.user
    @profile = @user.profile || @user.build_profile
  end
end
