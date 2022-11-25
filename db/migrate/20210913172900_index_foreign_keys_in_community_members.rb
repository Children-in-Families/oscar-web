class IndexForeignKeysInCommunityMembers < ActiveRecord::Migration[5.2]
  def change
    add_index :community_members, :community_id
    add_index :community_members, :family_id
  end
end
