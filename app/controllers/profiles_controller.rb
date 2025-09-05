class ProfilesController < ApplicationController
  before_action :set_user
  before_action :set_profile, only: [:update]

  def index
    @profile = @user.profile
  end

  def create
    @profile = @user.build_profile(profile_params)

    respond_to do |format|
      if @profile.save
        format.turbo_stream do
          redirect_to influencer_profile_path, notice: t("alerts.profiles.created")
        end
        format.html { redirect_to influencer_profile_path, notice: t("alerts.profiles.created") }
      else
        format.turbo_stream { render "influencers/form", status: :unprocessable_entity }
        format.html { render "influencers/form", status: :unprocessable_entity } # change from redirect_to
      end
    end
  end

  def update
    respond_to do |format|
      if @profile.update(profile_params)
        flash.now[:notice] = t("alerts.profiles.updated")

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "profile_progress",
              partial: "influencers/profile_progress",
              locals: { profile: @profile }
            ),
            turbo_stream.replace(
              "profile_form",
              partial: "influencers/form",
              locals: { profile: @profile }
            ),
            turbo_stream.replace(
              "flash",
              partial: "shared/flash"
            )
          ]
        end

        format.html { redirect_to influencer_profile_path, notice: t("alerts.profiles.updated") }
      else
        flash.now[:alert] = t("alerts.profiles.update_failed")

        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "profile_form",
              partial: "influencers/form",
              locals: { profile: @profile }
            ),
            turbo_stream.replace(
              "flash",
              partial: "shared/flash"
            )
          ], status: :unprocessable_entity
        end

        format.html { render "influencers/form", status: :unprocessable_entity }
      end
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
