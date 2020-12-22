class RenameColumnInFieldSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :field_settings, :visible, :boolean, default: true, null: false
    remove_column :field_settings, :hidden
  end
end
