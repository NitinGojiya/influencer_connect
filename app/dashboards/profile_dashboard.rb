require "administrate/base_dashboard"
require "administrate/field/active_storage"

class ProfileDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # A hash that describes the type of each of the model's fields.
  # Each type represents an Administrate::Field object, determining how
  # the attribute is displayed throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    bio: Field::String,
    city: Field::BelongsTo,
    content_type: Field::String,
    country: Field::String,
    dist: Field::String,
    full_name: Field::String,
    gender: Field::String,
    language: Field::String,
    mobile: Field::String,
    nickname: Field::String,
    profile_pic: Field::ActiveStorage, # Handles file uploads and previews
    social_platform: Field::HasOne,
    user: Field::BelongsTo,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # Attributes displayed on the index page.
  COLLECTION_ATTRIBUTES = %i[
    id
    full_name
    city
    profile_pic
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # Attributes displayed on the show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    full_name
    nickname
    bio
    gender
    content_type
    country
    dist
    language
    mobile
    city
    profile_pic
    social_platform
    user
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # Attributes displayed on the new/edit forms.
  FORM_ATTRIBUTES = %i[
    full_name
    nickname
    bio
    gender
    content_type
    country
    dist
    language
    mobile
    city
    profile_pic
    social_platform
    user
  ].freeze

  # COLLECTION_FILTERS
  # Custom filters for searching in the admin dashboard.
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how profiles are displayed
  # across all pages of the admin dashboard.
  def display_resource(profile)
    profile.full_name.presence || "Profile ##{profile.id}"
  end
end
