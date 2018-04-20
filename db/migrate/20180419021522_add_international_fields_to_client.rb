class AddInternationalFieldsToClient < ActiveRecord::Migration
  def change
    add_column :clients, :suburb, :string, default: ''
    add_column :clients, :description_house_landmark, :string, default: ''
    add_column :clients, :directions, :string, default: ''

    add_column :clients, :street_line1, :string, default: ''
    add_column :clients, :street_line2, :string, default: ''

    add_column :clients, :plot, :string, default: ''
    add_column :clients, :road, :string, default: ''
    add_column :clients, :postal_code, :string, default: ''
  end
end
