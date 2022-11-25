class IndexForeignKeysInSharedClients < ActiveRecord::Migration[5.2]
  def change
    add_index :shared_clients, :birth_province_id
    add_index :shared_clients, :external_case_worker_id
  end
end
