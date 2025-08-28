class UsersController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]
  def user_delete
    @user = Current.session.user

    if @user.destroy
      reset_session # log them out
      redirect_to root_path, notice: "Your account has been permanently deleted."
    else
      redirect_to profile_path, alert: "There was a problem deleting your account."
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # assign role via Rolify
      if params[:role].present?
        @user.add_role(params[:role])
      end

      start_new_session_for @user
      redirect_to after_authentication_url, notice: "Welcome new user, #{@user.email_address}!"
    else
      flash.now[:alert] = "Create account failed"
      render :new, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
