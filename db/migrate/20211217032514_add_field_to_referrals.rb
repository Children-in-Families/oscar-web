class AddFieldToReferrals < ActiveRecord::Migration
  def change
    add_column :referrals, :referral_status, :string, default: 'Referred'
  end
end
