class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create omniauth complete_google_signup finalize_google_signup]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  # Standard login
  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      if user.confirmed?  # only allow if email confirmed
        start_new_session_for user
        redirect_to after_authentication_url, notice: t("alerts.users.login", email: user.email_address)
      else
        redirect_to new_session_path, alert: "Please confirm your email address before logging in."
      end
    else
      redirect_to new_session_path, alert: I18n.t("alerts.auth.login_failed")
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, alert: I18n.t("alerts.auth.logged_out")
  end

  # Google OAuth callback
  def omniauth
    auth = request.env['omniauth.auth']
    email = auth.info.email

    user = User.find_by(email_address: email)

    if user.present?
      # Existing user: ensure confirmed and login
      user.update_columns(confirmed_at: Time.current, confirmation_token: nil) unless user.confirmed?
      start_new_session_for(user)
      redirect_to after_authentication_url, notice: I18n.t("alerts.signup.success", email: user.email_address)
    else
      # New user: store email in session and redirect to role selection
      session[:omniauth_email] = email
      redirect_to complete_google_signup_path
    end
  rescue => e
    Rails.logger.error("Google auth failed: #{e.message}")
    redirect_to new_session_path, alert: "Google login failed. Try again."
  end

  # GET: role selection page for new Google users
  def complete_google_signup
    email = session[:omniauth_email]

    # Redirect if no email in session
    unless email
      redirect_to root_path, alert: "No Google signup in progress."
      return
    end

    # Redirect if user already exists
    if User.exists?(email_address: email.downcase)
      start_new_session_for(User.find_by(email_address: email.downcase))
      session.delete(:omniauth_email)
      redirect_to after_authentication_url, notice: "Logged in successfully."
      return
    end

    # Otherwise, allow signup
    @user = User.new(email_address: email)
  end

  # POST: finalize Google signup with role selection
  def finalize_google_signup
    email = session[:omniauth_email]
    role = params[:user][:role_to_assign] || "influencer"

    # 1️⃣ Check if user already exists
    existing_user = User.find_by(email_address: email.downcase)
    if existing_user
      existing_user.update_columns(confirmed_at: Time.current, confirmation_token: nil) unless existing_user.confirmed?
      start_new_session_for(existing_user)
      session.delete(:omniauth_email)
      redirect_to after_authentication_url, notice: "Logged in successfully."
      return
    end

    # 2️⃣ Build new user
    @user = User.new(email_address: email)
    @user.role_to_assign = role
    @user.confirmed_at = Time.current
    @user.confirmation_token = nil

    # 3️⃣ Generate random password
    password = generate_strong_password
    @user.password = password
    @user.password_confirmation = password

    # 4️⃣ Save and assign role
    if @user.save
      @user.add_role(@user.role_to_assign)
      start_new_session_for(@user)
      session.delete(:omniauth_email)
      redirect_to after_authentication_url, notice: "Account created and logged in successfully."
    else
      # 5️⃣ Show errors if save fails
      flash.now[:alert] = @user.errors.full_messages.to_sentence
      render :complete_google_signup
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :role_to_assign)
  end

  def generate_strong_password
    # 12 chars: at least 1 uppercase, 1 lowercase, 1 digit, 1 symbol
    letters = ('a'..'z').to_a
    capitals = ('A'..'Z').to_a
    digits = ('0'..'9').to_a
    symbols = %w[! @ # $ % ^ & *]

    password = []
    password << letters.sample
    password << capitals.sample
    password << digits.sample
    password << symbols.sample
    password += (letters + capitals + digits + symbols).sample(8)
    password.shuffle.join
  end

end
