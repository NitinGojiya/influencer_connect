class Contact < ApplicationRecord
  # Subject must be present
  validates :subject, presence: true

  # Email must be present and valid format
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Message must be present
  validates :message, presence: true
end
