class AddCompletedToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :completed, :boolean, default: false
  end
end
