class RenameReferralDecision < ActiveRecord::Migration[5.2]
  def change
    rename_column :internal_referrals, :referral_decision, :crisis_management
  end
end
