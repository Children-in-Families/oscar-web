class AddAntiHumanTraffickingToOrganization < ActiveRecord::Migration[5.2]
  def up
    add_column :organizations, :aht, :boolean, default: false
  end

  def down
    remove_column :organizations, :aht
  end
end
