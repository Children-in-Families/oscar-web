class AddFieldToReferrals < ActiveRecord::Migration
  def up
    add_column :referrals, :referral_status, :string, default: 'Referred' unless column_exists? :referrals, :referral_status
  end

  def down
    remove_column :referrals, :referral_status
  end
end
