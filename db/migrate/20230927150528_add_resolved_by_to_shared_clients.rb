class AddResolvedByToSharedClients < ActiveRecord::Migration
  def change
    add_column :shared_clients, :resolved_duplication_by, :integer
    add_column :shared_clients, :resolved_duplication_at, :datetime
  end
end
