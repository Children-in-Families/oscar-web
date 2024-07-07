class AddFieldFeferredFromUidToFamilyReferrals < ActiveRecord::Migration
  def change
    add_column :family_referrals, :referral_status, :string, limit: 15, default: 'Referred'
    add_column :family_referrals, :referred_from_uid, :integer
    add_index :family_referrals, :referred_from_uid
  end
end
