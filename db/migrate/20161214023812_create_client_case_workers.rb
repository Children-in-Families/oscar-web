class CreateClientCaseWorkers < ActiveRecord::Migration
  def change
    create_table :client_case_workers do |t|
      t.references :user, index: true, foreign_key: true
      t.references :client, index: true, foreign_key: true
      t.boolean :active

      t.timestamps null: false
    end
  end
end
