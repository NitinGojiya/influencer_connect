class InfluencersController < ApplicationController
  before_action :require_influencer, only: [ :index, :profile ]
  layout "influencer"
  def index
    @user = Current.session.user
    @campaigns = Campaign.all
    @profile = @user.profile
    @business_new = User.with_role :business_owner
    # @campaigns = User.with_role(:business_owner).joins(:campaigns).count
  end

  def profile
    @user = Current.session.user
    @profile = @user.profile || @user.build_profile
  end
end
