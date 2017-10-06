class CreateClientType < ActiveRecord::Migration
  def change
    create_table :client_types do |t|
      t.string :name, default: ''
      t.timestamps
    end
  end
end
