class CreateGlobals < ActiveRecord::Migration
  def change
    create_table :globals do |t|
      t.string :ulid

      t.timestamps null: false
    end
    add_index :globals, :ulid
  end
end
