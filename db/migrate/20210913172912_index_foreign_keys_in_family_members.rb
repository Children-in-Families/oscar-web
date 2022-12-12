class IndexForeignKeysInFamilyMembers < ActiveRecord::Migration[5.2]
  def change
    add_index :family_members, :client_id unless index_exists? :family_members, :client_id
  end
end
