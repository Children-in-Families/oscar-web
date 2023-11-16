class AddEnabledInternalReferralFieldToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :enabled_internal_referral, :boolean, default: false
  end
end
