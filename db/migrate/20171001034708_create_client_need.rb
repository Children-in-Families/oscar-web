class CreateClientNeed < ActiveRecord::Migration[5.2]
  def change
    create_table :client_needs do |t|
      t.integer :rank
      t.references :client, index: true, foreign_key: true
      t.references :need, index: true, foreign_key: true
      t.timestamps
    end
  end
end
