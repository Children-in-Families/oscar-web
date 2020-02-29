class RemoveLabelFromFieldSetting < ActiveRecord::Migration
  def change
    remove_column :field_settings, :label
  end
end
