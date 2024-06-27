class AddIndexToSharedClientsResolvedDuplicationBy < ActiveRecord::Migration
  def change
    add_index :shared_clients, :resolved_duplication_by if column_exists?(:shared_clients, :resolved_duplication_by)
    add_index :shared_clients, :resolved_duplication_at if column_exists?(:shared_clients, :resolved_duplication_at)
  end
end
