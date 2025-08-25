class UsersController < ApplicationController
  def user_delete
    @user = Current.session.user

    if @user.destroy
      reset_session # log them out
      redirect_to root_path, notice: "Your account has been permanently deleted."
    else
      redirect_to profile_path, alert: "There was a problem deleting your account."
    end
  end
end
