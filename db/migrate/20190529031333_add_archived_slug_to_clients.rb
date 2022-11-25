class AddArchivedSlugToClients < ActiveRecord::Migration[5.2]
  def up
    add_column :clients, :archived_slug, :string, deafult: ''
    add_column :shared_clients, :archived_slug, :string, deafult: ''
  end

  def down
    remove_column :clients, :archived_slug
    remove_column :shared_clients, :archived_slug
  end
end
