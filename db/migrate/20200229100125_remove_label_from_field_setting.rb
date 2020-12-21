class RemoveLabelFromFieldSetting < ActiveRecord::Migration[5.2]
  def change
    remove_column :field_settings, :label
  end
end
