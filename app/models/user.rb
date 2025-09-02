class User < ApplicationRecord
  rolify
  has_secure_password
  attr_accessor :role_to_assign

  ALLOWED_ROLES = %w[influencer business_owner admin].freeze

  # Associations remain unchanged
  has_many :sessions, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_many :campaigns
  belongs_to :city, optional: true
  has_many :messages
  has_many :conversations, foreign_key: :sender_id

  before_create :generate_confirmation_token

  # Validations
  validates :email_address, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password,
            presence: true,
            format: { with: /\A(?=.*[a-z])(?=.*[A-Z])(?=.*[\W_]).{8,}\z/, message: "must be at least 8 characters long and include one uppercase letter, one lowercase letter, and one symbol" },
            if: :password_required?
  validate :role_to_assign_must_be_valid

  # Callbacks
  def generate_confirmation_token
    self.confirmation_token = SecureRandom.hex(10)
    self.confirmation_sent_at = Time.current
  end

  # Confirm user
  def confirm!
    update!(confirmed_at: Time.current, confirmation_token: nil)
  end

  def confirmed?
    confirmed_at.present?
  end

  private

  def password_required?
    new_record? || password.present?
  end

  def role_to_assign_must_be_valid
    if role_to_assign.blank? || !ALLOWED_ROLES.include?(role_to_assign)
      errors.add(:role_to_assign, "is not a valid role")
    end
  end
end
