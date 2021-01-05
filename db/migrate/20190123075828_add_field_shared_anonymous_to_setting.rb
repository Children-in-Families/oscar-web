class AddFieldSharedAnonymousToSetting < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :sharing_data, :boolean, default: false if !column_exists? :settings, :sharing_data
  end
end
