class AddDemoToOrganizations < ActiveRecord::Migration[5.2]
  def change
    add_column :organizations, :demo, :boolean, default: false

    reversible do |dir|
      dir.up do
        Organization.where(short_name: 'demo').update_all(demo: true)
      end
    end
  end
end
