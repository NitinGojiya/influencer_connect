class CampaignsController < ApplicationController
  before_action :set_user
  before_action :set_campaign, only: [ :edit, :update, :show, :destroy ]
  before_action :require_business_owner
  def index
    @campaigns = @user.campaigns.order(created_at: :desc)
  end

  def new
    @campaign = @user.campaigns.new
  end

  def create
    @campaign = @user.campaigns.new(campaign_params)

    if params[:city_id].present?
      # Existing city selected
      @campaign.city_id = params[:city_id]
    elsif params[:city_name].present?
      # New city typed, find or create it
      city = City.find_or_create_by(name: params[:city_name].strip)
      @campaign.city = city
    end

    if @campaign.save
      redirect_to campaigns_path, notice: t("alerts.campaigns.created")
    else
      flash.now[:alert] = t("alerts.campaigns.create_failed")
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @campaign.update(campaign_params)
      redirect_to campaigns_path, notice: t("alerts.campaigns.updated")
    else
      flash.now[:alert] = t("alerts.campaigns.update_failed")
      render :edit, status: :unprocessable_entity
    end
  end

  def show; end

  def destroy
    @campaign.destroy
    redirect_to campaigns_path, notice: t("alerts.campaigns.deleted")
  end

  private

  def set_user
    @user = Current.session.user
  end

  def set_campaign
    @campaign = @user.campaigns.find(params[:id])
  end

  def campaign_params
    params.require(:campaign).permit(
      :content_type,
      :deliverable_details,
      :key_messages,
      :tags_require,
      :creative_guidelines,
      :approval_deadline,
      :posting_start_date
    )
  end
end
