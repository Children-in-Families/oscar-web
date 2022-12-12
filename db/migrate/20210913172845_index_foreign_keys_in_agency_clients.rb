class IndexForeignKeysInAgencyClients < ActiveRecord::Migration[5.2]
  def change
    add_index :agency_clients, :agency_id unless index_exists? :agency_clients, :agency_id
    add_index :agency_clients, :client_id unless index_exists? :agency_clients, :client_id
  end
end
