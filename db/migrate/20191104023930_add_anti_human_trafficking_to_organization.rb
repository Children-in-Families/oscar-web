class AddAntiHumanTraffickingToOrganization < ActiveRecord::Migration
  def up
    add_column :organizations, :aht, :boolean, default: false
  end

  def down
    remove_column :organizations, :aht
  end
end
