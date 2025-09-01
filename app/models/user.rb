class User < ApplicationRecord
  rolify
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_one :city
  has_many :campaigns
  belongs_to :city, optional: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  has_many :messages
  has_many :conversations, foreign_key: :sender_id
  before_create :generate_confirmation_token

   # Validations
  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }

   # Generate a unique token before creating the user
  def generate_confirmation_token
    self.confirmation_token = SecureRandom.hex(10)
    self.confirmation_sent_at = Time.current
  end

  # Mark user as confirmed
  def confirm!
    update!(confirmed_at: Time.current, confirmation_token: nil)
  end

  # Check if confirmed
  def confirmed?
    confirmed_at.present?
  end
end
