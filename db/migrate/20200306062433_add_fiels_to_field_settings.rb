class AddFielsToFieldSettings < ActiveRecord::Migration
  def change
    add_column :field_settings, :current_label, :string
    add_column :field_settings, :required, :boolean, default: false
    add_column :field_settings, :model_name, :string
  end
end
