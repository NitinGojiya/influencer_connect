class AddColumnToProfile < ActiveRecord::Migration[8.0]
  def change
    add_column :profiles, :bio, :string
    add_column :profiles, :mobile, :string
  end
end
