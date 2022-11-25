class CreateAgencyClients < ActiveRecord::Migration[5.2]
  def change
    create_table :agency_clients do |t|
      t.references :agency
      t.references :client
      t.timestamps
    end
  end
end
