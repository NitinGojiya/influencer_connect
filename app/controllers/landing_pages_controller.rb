class LandingPagesController < ApplicationController
  # Allow unauthenticated access to specific actions
  allow_unauthenticated_access only: %i[index service support aboutus policy]

  # Set @user for all actions
  before_action :set_user

  def index
    # @user is already set by before_action
    @influencers = User.with_role(:influencer)
                   .includes(profile: [:city, :social_platform])
                   .select { |user| user.profile.present? && user.profile.social_platform.present? } # must have socials
                   .map do |inf|
    profile = inf.profile
    social  = profile.social_platform

    avg_followers = [
      social&.ig_followers.to_i,
      social&.youtube_subscriber.to_i,
      social&.twitter_followers.to_i
    ].sum / 3.0

    OpenStruct.new(
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
      content_quality: "9", # Placeholder
      language: profile.language,
      category: profile.content_type,
      mobile: profile.mobile.present?,
      mobile_number: profile.mobile,
      city: profile.city&.id&.to_s,
      city_name: profile.city&.name,
      avg_followers: avg_followers
    )
    end
    .sort_by { |inf| -inf.avg_followers } # sort descending
    .first(10) # take top 10

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
