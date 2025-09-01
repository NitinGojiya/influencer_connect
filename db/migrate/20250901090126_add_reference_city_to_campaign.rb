class AddReferenceCityToCampaign < ActiveRecord::Migration[8.0]
  def change
    add_reference :campaigns, :city, null: true, foreign_key: true
  end
end
