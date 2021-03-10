class AddFieldToCaseWorkerFamilies < ActiveRecord::Migration
  def change
    add_column :case_worker_families, :deleted_at, :datetime
    add_index :case_worker_families, :deleted_at
  end
end
