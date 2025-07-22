class AddFieldDisabledToServiceDelivery < ActiveRecord::Migration
  def change
    add_column :service_deliveries, :disabled, :boolean, default: false
  end
end
