class AddCountryToProvinces < ActiveRecord::Migration
  def change
    add_column :provinces, :country, :string
  end
end
