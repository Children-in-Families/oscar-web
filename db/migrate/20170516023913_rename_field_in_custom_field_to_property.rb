class RenameFieldInCustomFieldToProperty < ActiveRecord::Migration
  def change
    rename_column :custom_fields, :fields, :properties
  end
end
