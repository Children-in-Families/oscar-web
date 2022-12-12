class IndexForeignKeysInCaseWorkerCommunities < ActiveRecord::Migration[5.2]
  def change
    add_index :case_worker_communities, :community_id unless index_exists? :case_worker_communities, :community_id
    add_index :case_worker_communities, :user_id unless index_exists? :case_worker_communities, :user_id
  end
end
