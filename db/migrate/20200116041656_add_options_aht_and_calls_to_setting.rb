class AddOptionsAhtAndCallsToSetting < ActiveRecord::Migration
  def change
    add_column :settings, :enable_hotline, :boolean, default: false
    add_column :settings, :enable_client_form, :boolean, default: true
  end
end
