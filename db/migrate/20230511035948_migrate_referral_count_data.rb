class MigrateReferralCountData < ActiveRecord::Migration
  def change
    Client.update_all(referral_count: 0)

    Referral.find_each(&:inc_client_referral_count!)
  end
end
