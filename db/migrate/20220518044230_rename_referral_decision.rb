class RenameReferralDecision < ActiveRecord::Migration
  def change
    rename_column :internal_referrals, :referral_decision, :crisis_management
  end
end
