class User < ApplicationRecord
  rolify
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :profile, dependent: :destroy
  normalizes :email_address, with: ->(e) { e.strip.downcase }
  after_create :create_profile_record

  private

    def create_profile_record
      create_profile # Rails automatically builds it from association
    end
end
