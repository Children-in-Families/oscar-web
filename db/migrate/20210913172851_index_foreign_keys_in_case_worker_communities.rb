class IndexForeignKeysInCaseWorkerCommunities < ActiveRecord::Migration
  def change
    add_index :case_worker_communities, :community_id
    add_index :case_worker_communities, :user_id
  end
end
