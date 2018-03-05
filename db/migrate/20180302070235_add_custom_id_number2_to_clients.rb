class AddCustomIdNumber2ToClients < ActiveRecord::Migration
  def change
    add_column :clients, :custom_id_number2, :string
  end
end
