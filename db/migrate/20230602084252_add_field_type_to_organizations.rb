class AddFieldTypeToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :ngo_type, :string
  end
end
