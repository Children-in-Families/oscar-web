class AddOrganizationNameToCustomField < ActiveRecord::Migration[5.2]
  def up
    if column_exists? :custom_fields, :ngo_name
      remove_column :custom_fields, :ngo_name
    end
    add_column :custom_fields, :ngo_name, :string, default: ''
  end

  def down
    remove_column :custom_fields, :ngo_name
  end
end
