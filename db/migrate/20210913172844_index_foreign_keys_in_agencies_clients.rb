class IndexForeignKeysInAgenciesClients < ActiveRecord::Migration
  def change
    add_index :agencies_clients, :agency_id
    add_index :agencies_clients, :client_id
  end
end
