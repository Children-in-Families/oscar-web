class RenameColumnInFieldSettings < ActiveRecord::Migration
  def change
    add_column :field_settings, :visible, :boolean, default: true, null: false
    remove_column :field_settings, :hidden
  end
end
