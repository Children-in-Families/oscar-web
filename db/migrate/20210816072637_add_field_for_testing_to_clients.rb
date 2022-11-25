class AddFieldForTestingToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :for_testing, :boolean, default: false
  end
end
