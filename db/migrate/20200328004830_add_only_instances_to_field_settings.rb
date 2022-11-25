class AddOnlyInstancesToFieldSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :field_settings, :for_instances, :string
  end
end
