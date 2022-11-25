class IndexForeignKeysInCommunityDonors < ActiveRecord::Migration[5.2]
  def change
    add_index :community_donors, :community_id
    add_index :community_donors, :donor_id
  end
end
