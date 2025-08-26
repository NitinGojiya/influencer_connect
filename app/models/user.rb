class User < ApplicationRecord
  rolify
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_one :city
  belongs_to :city, optional: true
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  # after_create :create_profile_record

  # private

  # def create_profile_record
  #   create_profile unless profile.present?
  # end

end
