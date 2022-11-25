class AddPickupInfoToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :arrival_at, :datetime
    add_column :clients, :flight_nb, :string
  end
end
