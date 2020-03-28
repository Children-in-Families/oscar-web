class AddOnlyInstancesToFieldSettings < ActiveRecord::Migration
  def change
    add_column :field_settings, :for_instances, :string
  end
end
