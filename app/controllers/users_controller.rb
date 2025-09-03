class UsersController < ApplicationController
  allow_unauthenticated_access only: [:new, :create, :confirm]

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
    @user.role_to_assign = params[:user][:role] # virtual attribute for validation

    if @user.save
      # Assign the role via Rolify
      @user.add_role(@user.role_to_assign)
      UserMailer.confirmation_email(@user).deliver_later
      redirect_to root_path, notice: "Please check your email to confirm your account."
    else
      flash.now[:alert] = t("alerts.users.create_failed")
      render :new, status: :unprocessable_entity
    end
  end

  def confirm
    token = params[:token]
    user = User.find_by(confirmation_token: token)

    if user.nil? || user.confirmation_sent_at < 30.minutes.ago
      user&.destroy  # delete if token expired
      redirect_to root_path, alert: "Confirmation link expired. Please sign up again."
    else
      user.confirm!
      redirect_to new_session_path, notice: "Your account has been confirmed. Please log in."
    end
  end



  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
