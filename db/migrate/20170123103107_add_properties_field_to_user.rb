class AddPropertiesFieldToUser < ActiveRecord::Migration
  def change
    add_column :users, :properties, :text
  end
end
