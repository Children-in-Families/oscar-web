class AddCountryToProvinces < ActiveRecord::Migration[5.2]
  def change
    add_column :provinces, :country, :string
  end
end
