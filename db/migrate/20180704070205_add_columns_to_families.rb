class AddColumnsToFamilies < ActiveRecord::Migration[5.2]
  def change
    add_reference :families, :district, index: true, foreign_key: true
    add_column :families, :commune, :string, default: ''
    add_column :families, :village, :string, default: ''
  end
end
