class IndexForeignKeysInCases < ActiveRecord::Migration
  def change
    add_index :cases, :client_id
    add_index :cases, :family_id
    add_index :cases, :partner_id
    add_index :cases, :province_id
    add_index :cases, :user_id
  end
end
