class AddLocationsToClient < ActiveRecord::Migration
  def change
    add_column :clients, :concern_same_as_client, :boolean, default: false
    add_column :clients, :location_description, :string, default: ''
  end
end
