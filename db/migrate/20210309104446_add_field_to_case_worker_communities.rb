class AddFieldToCaseWorkerCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :case_worker_communities, :deleted_at, :datetime
    add_index :case_worker_communities, :deleted_at
  end
end
