class AddPropertiesFieldToClient < ActiveRecord::Migration
  def change
    add_column :clients, :properties, :text
  end
end
