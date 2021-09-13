class IndexForeignKeysInCommunityMembers < ActiveRecord::Migration
  def change
    add_index :community_members, :community_id
    add_index :community_members, :family_id
  end
end
