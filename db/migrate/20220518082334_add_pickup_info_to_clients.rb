class AddPickupInfoToClients < ActiveRecord::Migration
  def change
    add_column :clients, :arrival_at, :string
    add_column :clients, :flight_nb, :string
  end
end
