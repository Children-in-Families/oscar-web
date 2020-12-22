class RenameFieldSettings < ActiveRecord::Migration[5.2]
  def change
    rename_column :field_settings, :model_name, :klass_name
  end
end
