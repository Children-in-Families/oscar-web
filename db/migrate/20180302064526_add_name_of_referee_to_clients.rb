class AddNameOfRefereeToClients < ActiveRecord::Migration
  def change
    add_column :clients, :name_of_referee, :string
  end
end
