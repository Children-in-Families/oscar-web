class AddFieldDisabledAddNewServiceReceiveToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :disabled_add_service_received, :boolean, default: false
  end
end
