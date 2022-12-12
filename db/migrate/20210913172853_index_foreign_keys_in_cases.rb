class IndexForeignKeysInCases < ActiveRecord::Migration[5.2]
  def change
    add_index :cases, :client_id unless index_exists? :cases, :client_id
    add_index :cases, :family_id unless index_exists? :cases, :family_id
    add_index :cases, :partner_id unless index_exists? :cases, :partner_id
    add_index :cases, :province_id unless index_exists? :cases, :province_id
    add_index :cases, :user_id unless index_exists? :cases, :user_id
  end
end
