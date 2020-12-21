class AddLabelOnlyToFieldSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :field_settings, :label_only, :boolean, default: false
  end
end
