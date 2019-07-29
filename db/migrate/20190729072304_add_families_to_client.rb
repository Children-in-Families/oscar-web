class AddFamiliesToClient < ActiveRecord::Migration
  def change
    add_column :clients, :families, :string, array: true, default: []
  end
end
