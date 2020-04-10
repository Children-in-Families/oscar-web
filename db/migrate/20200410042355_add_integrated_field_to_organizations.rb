class AddIntegratedFieldToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :integrated, :boolean, default: false
  end
end
