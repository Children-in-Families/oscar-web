class AddArchivedByToClients < ActiveRecord::Migration
  def change
    add_column :clients, :archived_by_id, :integer
  end
end
