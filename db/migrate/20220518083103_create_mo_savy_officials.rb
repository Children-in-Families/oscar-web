class CreateMoSavyOfficials < ActiveRecord::Migration[5.2]
  def change
    create_table :mo_savy_officials do |t|
      t.string :name
      t.string :position
      t.integer :client_id

      t.timestamps null: false
    end
  end
end
