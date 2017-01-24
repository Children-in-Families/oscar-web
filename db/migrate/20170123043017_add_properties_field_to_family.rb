class AddPropertiesFieldToFamily < ActiveRecord::Migration
  def change
    add_column :families, :properties, :text
  end
end
