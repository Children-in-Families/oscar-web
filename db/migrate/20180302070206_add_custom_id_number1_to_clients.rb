class AddCustomIdNumber1ToClients < ActiveRecord::Migration
  def change
    add_column :clients, :custom_id_number1, :string
  end
end
