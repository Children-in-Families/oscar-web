class AddRatedForIdPoorToClients < ActiveRecord::Migration
  def change
    add_column :clients, :rated_for_id_poor, :boolean
  end
end
