class AddIndexOnFieldNameToFieldSettings < ActiveRecord::Migration
  def change
    add_index :field_settings, :name
  end
end
