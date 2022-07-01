class AddReferralDecisionToInternalReferrals < ActiveRecord::Migration
  def change
    add_column :internal_referrals, :referral_decision, :string
  end
end
