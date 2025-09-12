require "administrate/base_dashboard"

class CampaignDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    approval_deadline: Field::DateTime,
    city: Field::BelongsTo,
    content_type: Field::String,
    creative_guidelines: Field::Text,
    deliverable_details: Field::String,
    key_messages: Field::Text,
    posting_start_date: Field::DateTime,
    tags_require: Field::String,
    user: Field::BelongsTo,
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
    approval_deadline
    city
    content_type
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    approval_deadline
    city
    content_type
    creative_guidelines
    deliverable_details
    key_messages
    posting_start_date
    tags_require
    user
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    approval_deadline
    city
    content_type
    creative_guidelines
    deliverable_details
    key_messages
    posting_start_date
    tags_require
    user
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

  # Overwrite this method to customize how campaigns are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(campaign)
  #   "Campaign ##{campaign.id}"
  # end
end
