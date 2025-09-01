class UserMailer < ApplicationMailer
  default from: "nitingojiya2000@gmail.com"  # Replace with your sender email

  # Confirmation email
  def confirmation_email(user)
    @user = user
    @url  = confirm_users_url(token: @user.confirmation_token)
    mail(to: @user.email_address, subject: "Confirm your account")
  end
end
