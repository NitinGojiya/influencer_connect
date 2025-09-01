class UsersController < ApplicationController
  allow_unauthenticated_access only: [:new, :create]

  def user_delete
    @user = Current.session.user

    if @user.destroy
      reset_session # log them out
      redirect_to root_path, notice: t("alerts.users.deleted")
    else
      redirect_to profile_path, alert: t("alerts.users.delete_failed")
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # Assign role via Rolify if provided
      @user.add_role(params[:role]) if params[:role].present?

      start_new_session_for @user
      redirect_to after_authentication_url, notice: t("alerts.users.created", email: @user.email_address)
    else
      flash.now[:alert] = t("alerts.users.create_failed")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
