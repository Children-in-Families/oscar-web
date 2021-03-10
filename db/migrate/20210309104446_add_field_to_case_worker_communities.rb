class AddFieldToCaseWorkerCommunities < ActiveRecord::Migration
  def change
    add_column :case_worker_communities, :deleted_at, :datetime
    add_index :case_worker_communities, :deleted_at
  end
end
