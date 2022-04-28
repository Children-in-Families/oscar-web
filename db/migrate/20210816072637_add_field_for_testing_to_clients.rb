class AddFieldForTestingToClients < ActiveRecord::Migration
  def change
    add_column :clients, :for_testing, :boolean, default: false
  end
end
