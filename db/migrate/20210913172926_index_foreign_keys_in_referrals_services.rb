class IndexForeignKeysInReferralsServices < ActiveRecord::Migration[5.2]
  def change
    add_index :referrals_services, :referral_id
    add_index :referrals_services, :service_id
  end
end
