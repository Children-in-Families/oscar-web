class IndexForeignKeysInExternalSystemGlobalIdentities < ActiveRecord::Migration
  def change
    add_index :external_system_global_identities, :external_id
  end
end
