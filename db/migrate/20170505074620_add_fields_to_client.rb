class AddFieldsToClient < ActiveRecord::Migration
  def change
  	add_column :clients, :house_num, :string
  	add_column :clients, :street_num, :string
  	add_column :clients, :village, :string
  	add_column :clients, :commune, :string
  	add_column :clients, :district, :string
  end
end
