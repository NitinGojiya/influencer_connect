require "administrate/base_dashboard"

class SocialPlatformDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    ig_followers: Field::String,
    ig_id: Field::String,
    ig_link: Field::String,
    profile: Field::BelongsTo,
    twitter_followers: Field::String,
    twitter_id: Field::String,
    twitter_link: Field::String,
    versions: Field::HasMany,
    youtube_id: Field::String,
    youtube_link: Field::String,
    youtube_subscriber: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    ig_followers
    ig_id
    ig_link
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    ig_followers
    ig_id
    ig_link
    profile
    twitter_followers
    twitter_id
    twitter_link
    versions
    youtube_id
    youtube_link
    youtube_subscriber
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    ig_followers
    ig_id
    ig_link
    profile
    twitter_followers
    twitter_id
    twitter_link
    versions
    youtube_id
    youtube_link
    youtube_subscriber
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how social platforms are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(social_platform)
  #   "SocialPlatform ##{social_platform.id}"
  # end
end
