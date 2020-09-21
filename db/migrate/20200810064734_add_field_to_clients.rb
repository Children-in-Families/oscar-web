class AddFieldToClients < ActiveRecord::Migration
  def change
    add_column :clients, :locality, :string
  end
end
