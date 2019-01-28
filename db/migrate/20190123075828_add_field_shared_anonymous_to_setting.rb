class AddFieldSharedAnonymousToSetting < ActiveRecord::Migration
  def change
    add_column :settings, :sharing_data, :boolean, default: false
  end
end
