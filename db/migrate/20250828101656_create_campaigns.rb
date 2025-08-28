class CreateCampaigns < ActiveRecord::Migration[8.0]
  def change
    create_table :campaigns do |t|
      t.string :content_type
      t.string :deliverable_details
      t.text :key_messages
      t.string :tags_require
      t.text :creative_guidelines
      t.datetime :approval_deadline
      t.datetime :posting_start_date
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
