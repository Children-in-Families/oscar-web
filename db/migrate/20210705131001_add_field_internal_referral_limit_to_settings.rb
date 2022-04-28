class AddFieldInternalReferralLimitToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :internal_referral_limit, :integer, default: 0
    add_column :settings, :internal_referral_frequency, :string, default: "week"
  end
end
