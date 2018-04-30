class AddSpecificReferralDataFieldsToPermission < ActiveRecord::Migration
  def change
    add_column :permissions, :specific_referral_data_editable, :boolean, default: false
    add_column :permissions, :specific_referral_data_readable, :boolean, default: false
  end
end
