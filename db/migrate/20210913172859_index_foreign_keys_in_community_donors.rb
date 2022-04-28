class IndexForeignKeysInCommunityDonors < ActiveRecord::Migration
  def change
    add_index :community_donors, :community_id
    add_index :community_donors, :donor_id
  end
end
