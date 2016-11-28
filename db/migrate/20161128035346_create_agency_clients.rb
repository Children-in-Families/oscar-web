class CreateAgencyClients < ActiveRecord::Migration
  def change
    create_table :agency_clients do |t|
      t.references :agency
      t.references :client
      t.timestamps
    end
  end
end
