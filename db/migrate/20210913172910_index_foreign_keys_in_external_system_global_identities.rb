class IndexForeignKeysInExternalSystemGlobalIdentities < ActiveRecord::Migration[5.2]
  def change
    add_index :external_system_global_identities, :external_id
  end
end
