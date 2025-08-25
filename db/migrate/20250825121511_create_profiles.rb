class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.string :full_name
      t.string :nickname
      t.string :gender
      t.string :country
      t.string :dist
      t.string :language
      t.string :content_type
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
