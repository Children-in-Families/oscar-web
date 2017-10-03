class CreateClientClientType < ActiveRecord::Migration
  def change
    create_table :client_client_types do |t|
      t.references :client, index: true, foreign_key: true
      t.references :client_type, index: true, foreign_key: true
      t.timestamps
    end
  end
end
