class AddClientAgreegationToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :clients_count, :integer, default: 0
    add_column :organizations, :active_client, :integer, default: 0
    add_column :organizations, :accepted_client, :integer, default: 0
  end
end
