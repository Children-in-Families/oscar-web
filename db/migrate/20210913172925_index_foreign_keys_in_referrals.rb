class IndexForeignKeysInReferrals < ActiveRecord::Migration[5.2]
  def change
    add_index :referrals, :external_case_worker_id
    add_index :referrals, :referee_id
  end
end
