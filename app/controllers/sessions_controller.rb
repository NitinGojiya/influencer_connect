class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

   def omniauth
    auth = request.env['omniauth.auth']
    email = auth.info.email

    user = User.find_by(email_address: email)

    if user.nil?
      # Create user with random password, skipping validations if needed
      user = User.new(email_address: email)
      password = strong_random_password
      user.password = password
      user.password_confirmation = password

      if user.save
        start_new_session_for user
        redirect_to after_authentication_url,
                    notice: I18n.t("alerts.signup.success", email: user.email_address)
      else
        redirect_to new_user_path,
                    alert: I18n.t("alerts.signup.failure", errors: user.errors.full_messages.to_sentence)
      end
    else
      start_new_session_for(user)
      redirect_to after_authentication_url, notice: I18n.t("alerts.signup.success", email: user.email_address)
    end
  rescue => e
    Rails.logger.error("Google auth failed: #{e.message}")
    redirect_to new_session_path, alert: "Google login failed. Try again."
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url, notice: I18n.t("alerts.user.created")
    else
      redirect_to new_session_path, alert: I18n.t("alerts.auth.login_failed")
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, alert: I18n.t("alerts.auth.logged_out")
  end
end
