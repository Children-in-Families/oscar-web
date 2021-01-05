class AddFieldsToClient < ActiveRecord::Migration[5.2]
  def change
  	add_column :clients, :house_number, :string, default: ''
  	add_column :clients, :street_number, :string, default: ''
  	add_column :clients, :village, :string, default: ''
  	add_column :clients, :commune, :string, default: ''
  	add_column :clients, :district, :string, default: ''
  end
end
