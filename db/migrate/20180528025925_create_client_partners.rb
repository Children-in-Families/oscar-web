class CreateClientPartners < ActiveRecord::Migration
  def change
    create_table :client_partners do |t|
      t.references :client, index: true, foreign_key: true
      t.references :partner, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
