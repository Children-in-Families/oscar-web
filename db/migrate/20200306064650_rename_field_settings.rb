class RenameFieldSettings < ActiveRecord::Migration
  def change
    rename_column :field_settings, :model_name, :klass_name
  end
end
