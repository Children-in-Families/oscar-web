class AddPropertiesFieldToPartner < ActiveRecord::Migration
  def change
    add_column :partners, :properties, :text, default: ''
  end
end
