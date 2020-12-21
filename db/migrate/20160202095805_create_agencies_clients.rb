class CreateAgenciesClients < ActiveRecord::Migration[5.2]
  def change
    create_table :agencies_clients do |t|
      t.references :client
      t.references :agency

      t.timestamps
    end
  end
end
