class ContactsController < ApplicationController
  allow_unauthenticated_access only: [:create]
  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      ContactMailer.contact_email(@contact).deliver_later
      redirect_to support_path, notice: "Your support request has been sent successfully."
    else
      # Render the support page again with the invalid @contact object
      render "landing_pages/support", notice: "There was an error sending your support request.", status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :subject, :message)
  end
end
