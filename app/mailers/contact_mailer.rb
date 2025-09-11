class ContactMailer < ApplicationMailer
  default to: "nitingojiya2000@gmail.com" # change to  support email

  def contact_email(contact)
    @contact = contact
    mail(
      from: @contact.email,
      subject: "Your Contact Request to influencer connect: #{@contact.subject}"
    )
  end
end
