require "administrate/base_dashboard"

class PaperTrail::VersionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    item: Field::Polymorphic,
    event: Field::String,
    whodunnit: Field::String,
    object: Field::Text,
    object_changes: Field::Text,
    created_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[
    id
    item
    event
    whodunnit
    created_at
  ].freeze

  SHOW_PAGE_ATTRIBUTES = ATTRIBUTE_TYPES.keys.freeze
  FORM_ATTRIBUTES = [].freeze

  def display_resource(version)
    "#{version.item_type} ##{version.item_id} (#{version.event})"
  end
end
