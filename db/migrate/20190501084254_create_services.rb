class CreateServices < ActiveRecord::Migration[5.2]
  def change
    create_table :services do |t|
      t.string :name
      t.integer :parent_id
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_index :services, :name
    add_index :services, :parent_id
    add_index :services, :deleted_at
  end
end
