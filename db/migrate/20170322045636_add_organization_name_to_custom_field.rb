class AddOrganizationNameToCustomField < ActiveRecord::Migration
  def change
    add_column :custom_fields, :ngo_name, :string, default: ''
  end
end
