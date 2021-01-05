class AddIntegratedFieldsToSharedClients < ActiveRecord::Migration[5.2]
  def change
    add_column :shared_clients, :external_id, :string
    add_index :shared_clients, :external_id
    add_column :shared_clients, :external_id_display, :string
    add_column :shared_clients, :mosvy_number, :string
    add_index :shared_clients, :mosvy_number
    add_column :shared_clients, :external_case_worker_name, :string
    add_column :shared_clients, :external_case_worker_id, :string
  end
end
