class AddOptionsAhtAndCallsToSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :enable_hotline, :boolean, default: false     if !column_exists? :settings, :enable_hotline
    add_column :settings, :enable_client_form, :boolean, default: true  if !column_exists? :settings, :enable_client_form
  end
end
