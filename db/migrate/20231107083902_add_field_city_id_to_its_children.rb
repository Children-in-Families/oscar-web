class AddFieldCityIdToItsChildren < ActiveRecord::Migration
  def change
    add_column :clients, :city_id, :integer
    add_index :clients, :city_id

    add_column :families, :city_id, :integer
    add_index :families, :city_id

    add_column :communities, :city_id, :integer
    add_index :communities, :city_id

    add_column :referees, :city_id, :integer
    add_index :referees, :city_id

    add_column :carers, :city_id, :integer
    add_index :carers, :city_id

    add_column :settings, :city_id, :integer
    add_index :settings, :city_id
  end
end
