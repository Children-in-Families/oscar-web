class AddIndexOnFieldNameToFieldSettings < ActiveRecord::Migration[5.2]
  def change
    add_index :field_settings, :name
  end
end
