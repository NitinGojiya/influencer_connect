class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :city, optional: true
  has_one_attached :profile_pic
  has_one :social_platform
  attr_accessor :city_name

  before_validation :assign_city

  # ✅ Validations
  validates :full_name, presence: true
  validates :content_type, presence: true
  validates :mobile, presence: true,
                     format: { with: /\A[0-9]{10,15}\z/, message: "must be a valid number (10–15 digits)" }

  private

  def assign_city
    return if city_name.blank?

    found_city = City.find_or_create_by!(name: city_name.strip.titleize)
    self.city = found_city
  end
end
