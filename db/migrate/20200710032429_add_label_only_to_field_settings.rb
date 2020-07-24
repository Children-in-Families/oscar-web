class AddLabelOnlyToFieldSettings < ActiveRecord::Migration
  def change
    add_column :field_settings, :label_only, :boolean, default: false
  end
end
