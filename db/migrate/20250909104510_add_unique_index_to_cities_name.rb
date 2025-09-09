class AddUniqueIndexToCitiesName < ActiveRecord::Migration[8.0]
  def change
    add_index :cities, "LOWER(name)", unique: true, name: "index_cities_on_lower_name"
  end
end
