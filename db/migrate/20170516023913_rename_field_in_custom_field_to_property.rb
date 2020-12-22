class RenameFieldInCustomFieldToProperty < ActiveRecord::Migration[5.2]
  def change
    rename_column :custom_fields, :fields, :properties
  end
end
