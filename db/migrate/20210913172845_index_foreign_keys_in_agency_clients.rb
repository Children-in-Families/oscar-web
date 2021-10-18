class IndexForeignKeysInAgencyClients < ActiveRecord::Migration
  def change
    add_index :agency_clients, :agency_id
    add_index :agency_clients, :client_id
  end
end
