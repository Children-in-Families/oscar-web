class AddIntegratedDateToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :last_integrated_date, :date
  end
end
