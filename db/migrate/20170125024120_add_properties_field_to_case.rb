class AddPropertiesFieldToCase < ActiveRecord::Migration
  def change
    add_column :cases, :properties, :text
  end
end
