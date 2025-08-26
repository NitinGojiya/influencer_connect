class Profile < ApplicationRecord
  belongs_to :user
  belongs_to :city, optional: true  # optional for initial creation
  has_one_attached :profile_pic
  has_one :social_platform
  attr_accessor :city_name

  before_validation :assign_city


  private

  def assign_city
    return if city_name.blank?

    # Use find_or_create_by! to ensure the city exists and assign it
    found_city = City.find_or_create_by!(name: city_name.strip.titleize)
    self.city = found_city
  end

end
