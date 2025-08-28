class AddFieldParentIdToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :parent_id, :integer if !column_exists?(:organizations, :parent_id)
  end
end
