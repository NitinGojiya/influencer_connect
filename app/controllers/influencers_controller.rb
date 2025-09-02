class InfluencersController < ApplicationController
  before_action :require_influencer, only: [ :index, :profile ]
  layout "influencer"
  def index
    @user = Current.session.user
profile = @user.profile

if profile.present?
  social = profile.social_platform

  @influencer_card = OpenStruct.new(
    email: profile.user.email_address,
    receiver_id: profile.user.id,
    photo_url: profile.profile_pic.attached? ? url_for(profile.profile_pic) : nil,
    name: profile.full_name,
    bio: profile.bio,
    ig_link: social&.ig_link,
    instagram_followers: social&.ig_followers,
    youtube_subscribers: social&.youtube_subscriber,
    twitter_followers: social&.twitter_followers,
    youtube_link: social&.youtube_link,
    twitter_link: social&.twitter_link,
    content_quality: "9",
    language: profile.language,
    category: profile.content_type,
    mobile: profile.mobile.present?,
    mobile_number: profile.mobile,
    city: profile.city&.id&.to_s
  )
else
  @influencer_card = nil
end

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
