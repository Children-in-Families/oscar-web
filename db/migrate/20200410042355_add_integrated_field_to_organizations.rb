class AddIntegratedFieldToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :integrated, :boolean, default: false
  end
end
