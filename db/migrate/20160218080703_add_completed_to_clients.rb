class AddCompletedToClients < ActiveRecord::Migration
  def change
    add_column :clients, :completed, :boolean, default: false
  end
end
