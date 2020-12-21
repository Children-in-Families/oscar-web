class AddFieldToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :locality, :string
  end
end
