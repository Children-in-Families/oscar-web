class AddProfileToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :profile, :string
  end
end
