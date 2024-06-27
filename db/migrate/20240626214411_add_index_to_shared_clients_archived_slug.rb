class AddIndexToSharedClientsArchivedSlug < ActiveRecord::Migration
  def change
    add_index :shared_clients, :archived_slug
  end
end
