class ProfilesController < ApplicationController
  def index
    @user = Current.session.user
    @profile = @user.profile
  end

  def create
    @user = Current.session.user
    @profile = @user.build_profile(profile_params)

    if @profile.save
      redirect_to profile_path, notice: "Profile created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:full_name, :nickname, :gender, :country, :dist, :language, :content_type, :profile_pic,:city_name)
  end
end
