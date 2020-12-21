class AddAddressFieldsToFamilies < ActiveRecord::Migration[5.2]
  def change
    add_column :families, :house, :string, default: ''
    add_column :families, :street, :string, default: ''
  end
end
