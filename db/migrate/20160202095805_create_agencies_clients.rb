class CreateAgenciesClients < ActiveRecord::Migration
  def change
    create_table :agencies_clients do |t|
      t.references :client
      t.references :agency

      t.timestamps
    end
  end
end
