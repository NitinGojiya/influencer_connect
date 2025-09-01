class InfluencersController < ApplicationController
  before_action :require_influencer, only: [ :index, :profile ]
  layout "influencer"
  def index
    @user = Current.session.user
    @campaigns = Campaign.all.order(created_at: :desc)
    @profile = @user.profile
    @business_new = User.with_role :business_owner
    # @campaigns = User.with_role(:business_owner).joins(:campaigns).count
      if params[:city_id].present?
        @campaigns = @campaigns.where( city_id: params[:city_id]).order(created_at: :desc)
      end

      @traffic_by_city = Campaign
      .joins(:city)
      .group('cities.id')          # group by city row
      .select('cities.name AS location, COUNT(campaigns.id) AS traffic')
      .order('traffic DESC')
  end

  def profile
    @user = Current.session.user
    @profile = @user.profile || @user.build_profile
  end
end
