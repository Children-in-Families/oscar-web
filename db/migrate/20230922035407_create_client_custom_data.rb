class CreateClientCustomData < ActiveRecord::Migration
  def change
    create_table :client_custom_data do |t|
      t.references :client, index: true, foreign_key: true
      t.jsonb :properties

      t.timestamps null: false
    end

    ClientCustomData.reset_column_information
    add_column :client_custom_data, :custom_data_id, :integer, index: true
    add_foreign_key :client_custom_data, :custom_data, column: :custom_data_id
  end
end
