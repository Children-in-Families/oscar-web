class AddAddressFieldsToFamilies < ActiveRecord::Migration
  def change
    add_column :families, :house, :string, default: ''
    add_column :families, :street, :string, default: ''
  end
end
