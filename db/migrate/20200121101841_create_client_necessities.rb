class CreateClientNecessities < ActiveRecord::Migration[5.2]
  def change
    create_table :client_necessities do |t|
      t.references :client, index: true, foreign_key: true
      t.references :necessity, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
