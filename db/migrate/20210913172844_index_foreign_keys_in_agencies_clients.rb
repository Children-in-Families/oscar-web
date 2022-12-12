class IndexForeignKeysInAgenciesClients < ActiveRecord::Migration[5.2]
  def change
    add_index :agencies_clients, :agency_id unless index_exists? :agencies_clients, :agency_id
    add_index :agencies_clients, :client_id unless index_exists? :agencies_clients, :client_id
  end
end
