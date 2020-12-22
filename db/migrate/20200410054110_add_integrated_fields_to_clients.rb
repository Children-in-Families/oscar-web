class AddIntegratedFieldsToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :external_id, :string
    add_index :clients, :external_id
    add_column :clients, :external_id_display, :string
    add_column :clients, :mosvy_number, :string
    add_index :clients, :mosvy_number
    add_column :clients, :external_case_worker_name, :string
    add_column :clients, :external_case_worker_id, :string
  end
end
