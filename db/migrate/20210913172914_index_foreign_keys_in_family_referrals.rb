class IndexForeignKeysInFamilyReferrals < ActiveRecord::Migration
  def change
    add_index :family_referrals, :referee_id
  end
end
