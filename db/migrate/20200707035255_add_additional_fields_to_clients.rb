class AddAdditionalFieldsToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :marital_status, :string
    add_column :clients, :nationality, :string
    add_column :clients, :ethnicity, :string
    add_column :clients, :location_of_concern, :string
    add_column :clients, :type_of_trafficking, :string
    add_column :clients, :education_background, :text
    add_column :clients, :department, :string
  end
end
