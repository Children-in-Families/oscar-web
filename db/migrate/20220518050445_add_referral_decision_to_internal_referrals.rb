class AddReferralDecisionToInternalReferrals < ActiveRecord::Migration[5.2]
  def change
    add_column :internal_referrals, :referral_decision, :string
  end
end
