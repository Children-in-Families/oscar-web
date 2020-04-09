class AddClientGlobalIdToReferrals < ActiveRecord::Migration
  def change
    add_column :referrals, :client_global_id, :integer
    add_index :referrals, :client_global_id
  end
end
