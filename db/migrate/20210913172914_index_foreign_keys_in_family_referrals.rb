class IndexForeignKeysInFamilyReferrals < ActiveRecord::Migration[5.2]
  def change
    add_index :family_referrals, :referee_id unless index_exists? :family_referrals, :referee_id
  end
end
