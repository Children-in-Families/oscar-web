class AddFieldCountryNameToClients < ActiveRecord::Migration
  def up
    add_column :clients, :country_origin, :string, default: 'cambodia'
    setting = Setting.first
    Client.update_all(country_origin: setting.country_name)
  end

  def down
    remove_column :clients, :country_origin
  end
end
