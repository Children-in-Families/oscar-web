class AddCountryOriginToClient < ActiveRecord::Migration
  def up
    add_column :clients, :country_origin, :string, default: ''
    add_column :shared_clients, :country_origin, :string, default: ''
    setting = Setting.first
    Client.update_all(country_origin: setting.country_name) if setting.present?
  end

  def down
    remove_column :clients, :country_origin
    remove_column :shared_clients, :country_origin
  end
end
