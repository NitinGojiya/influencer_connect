class CampaignsController < ApplicationController
  def index
    # load current user's campaigns in newest-first order
    @user = Current.session.user
    @campaigns = @user.campaigns.order(created_at: :desc)
  end

  def new
    @user = Current.session.user
    @campaign = @user.campaigns.new
  end

  def create
    @campaign = Current.session.user.campaigns.new(campaign_params)
    if @campaign.save
      redirect_to campaigns_path, notice: "Campaign created successfully."
    else
      render campaigns_path, status: :unprocessable_entity
    end
  end

  def edit
    @user = Current.session.user
    @campaign = Current.session.user.campaigns.find(params[:id])
  end

  def update
    @campaign = Current.session.user.campaigns.find(params[:id])

    if @campaign.update(campaign_params)
      redirect_to campaigns_path, notice: "Campaign updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

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
