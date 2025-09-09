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

  def completeness_percentage
    fields = [:full_name, :nickname, :gender, :country, :dist, :language, :content_type, :city_id, :bio, :mobile]
    filled_count = fields.count { |field| self.send(field).present? }

    # Include profile picture in completeness
    filled_count += 1 if profile_pic.attached?

    total_fields = fields.size + 1 # adding profile_pic
    (filled_count.to_f / total_fields * 100).round
  end

  private

  def assign_city
    return if city_name.blank?

    normalized = city_name.strip.titleize

    # Case-insensitive lookup
    found_city = City.where("LOWER(name) = ?", normalized.downcase).first_or_create!(name: normalized)

    self.city = found_city
  end


end
