class ChangeEntityNameToEntityTypeInCustomFields < ActiveRecord::Migration
  def change
    rename_column :custom_fields, :entity_type, :entity_type
  end
end
