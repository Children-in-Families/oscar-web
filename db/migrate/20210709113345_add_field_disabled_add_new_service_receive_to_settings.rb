class AddFieldDisabledAddNewServiceReceiveToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :disabled_add_service_received, :boolean, default: false
  end
end
