class ProfilesController < ApplicationController
  before_action :set_profile, only: [:update]

  def index
    @user = Current.session.user
    @profile = @user.profile
  end

  def create
    @user = Current.session.user
    @profile = @user.build_profile(profile_params)

    if @profile.save
      redirect_to influencer_profile_path, notice: "Profile created successfully."
    else
      render influencer_profile, status: :unprocessable_entity
    end
  end

  def update
    @user = Current.session.user
    @profile = @user.profile

    if @profile.update(profile_params)
      redirect_to influencer_profile_path, notice: "Profile updated successfully."
    else
      render influencer_profile, status: :unprocessable_entity
    end
  end

  private

  def set_profile
    @profile = Current.session.user.profile
  end

  def profile_params
    params.require(:profile).permit(:full_name, :nickname, :gender, :country, :dist, :language, :content_type, :profile_pic, :city_name,:mobile,:bio)
  end
end
