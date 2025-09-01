class ProfilesController < ApplicationController
  before_action :set_user
  before_action :set_profile, only: [:update]

  def index
    @profile = @user.profile
  end

  def create
    @profile = @user.build_profile(profile_params)

    if @profile.save
      redirect_to influencer_profile_path, notice: t("alerts.profiles.created")
    else
      flash.now[:alert] = t("alerts.profiles.create_failed")
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @profile.update(profile_params)
      redirect_to influencer_profile_path, notice: t("alerts.profiles.updated")
    else
      flash.now[:alert] = t("alerts.profiles.update_failed")
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = Current.session.user
  end

  def set_profile
    @profile = @user.profile
  end

  def profile_params
    params.require(:profile).permit(
      :full_name,
      :nickname,
      :gender,
      :country,
      :dist,
      :language,
      :content_type,
      :profile_pic,
      :city_name,
      :mobile,
      :bio
    )
  end
end
