class BusinessOwnersController < ApplicationController
  before_action :require_business_owner, only: [:index]

  def index
    @user = Current.session.user

    # --- 🔹 Base Query: Influencers with Profiles and Cities ---
    influencers = User.with_role(:influencer).includes(profile: :city)



    # --- 🔹 Build OpenStructs for View ---
    # Load influencers into OpenStructs first
    @influencers = User.with_role(:influencer)
                   .includes(profile: [:city, :social_platform])
                   .map do |inf|
          profile = inf.profile
          social  = profile&.social_platform

          OpenStruct.new(
            photo_url: profile&.profile_pic&.attached? ? url_for(profile.profile_pic) : nil,
            name: profile&.full_name,
            bio: profile&.bio,
            ig_link: social&.ig_link,
            youtube_link: social&.youtube_link,
            twitter_link: social&.twitter_link,
            content_quality: "9", # You can calculate this later if needed
            language: profile&.language,
            category: profile&.content_type,
            mobile: profile&.mobile.present?,   # true/false depending on if number exists
            mobile_number: profile&.mobile,
            city: profile&.city&.id&.to_s
          )
        end


    # Apply filters
    if params[:q].present?
      query = params[:q].downcase
      @influencers = @influencers.select do |inf|
        inf.name.to_s.downcase.include?(query) ||
        inf.bio.to_s.downcase.include?(query) ||
        inf.city.to_s.downcase.include?(query) ||
        inf.language.to_s.downcase.include?(query)
      end
    end

    if params[:type].present? && params[:type] != "Influencer Type"
      @influencers = @influencers.select { |inf| inf.category == params[:type] }
    end

    if params[:city_id].present?
      @influencers = @influencers.select { |inf| inf.city == params[:city_id] }
    end


    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end
end
