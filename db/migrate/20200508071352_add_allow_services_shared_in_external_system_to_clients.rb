class AddAllowServicesSharedInExternalSystemToClients < ActiveRecord::Migration
  def change
    add_column :clients, :shared_service_enabled, :boolean, default: false
  end
end
