class CreateClientCustomFields < ActiveRecord::Migration[5.2]
  def change
    create_table :client_custom_fields do |t|
      t.text :properties
      t.references :client, index: true, foreign_key: true
      t.references :custom_field, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
