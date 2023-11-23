class AddCityIdToDistricts < ActiveRecord::Migration
  def change
    add_column :districts, :city_id, :integer
    add_index :districts, :city_id
  end
end
