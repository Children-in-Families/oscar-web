class AddProfileToClients < ActiveRecord::Migration
  def change
    add_column :clients, :profile, :string
  end
end
