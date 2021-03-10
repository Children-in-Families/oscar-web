class AddFieldToCaseWorkerClients < ActiveRecord::Migration
  def change
    add_column :case_worker_clients, :deleted_at, :datetime
    add_index :case_worker_clients, :deleted_at
  end
end
