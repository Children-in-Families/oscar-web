class IndexForeignKeysInReferrals < ActiveRecord::Migration
  def change
    add_index :referrals, :external_case_worker_id
    add_index :referrals, :referee_id
  end
end
