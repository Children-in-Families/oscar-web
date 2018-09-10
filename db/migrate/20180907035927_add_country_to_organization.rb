class AddCountryToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :country, :string, default: ''
  end
end
