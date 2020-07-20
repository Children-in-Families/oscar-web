class AddAllowServicesSharedInExternalSystemToClients < ActiveRecord::Migration
  def change
    add_column :clients, :referred_external, :boolean, default: false
  end
end
