class AddPropertiesFieldToPartner < ActiveRecord::Migration
  def change
    add_column :partners, :properties, :text
  end
end
