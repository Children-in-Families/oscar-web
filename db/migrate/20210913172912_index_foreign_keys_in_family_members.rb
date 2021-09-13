class IndexForeignKeysInFamilyMembers < ActiveRecord::Migration
  def change
    add_index :family_members, :client_id
  end
end
