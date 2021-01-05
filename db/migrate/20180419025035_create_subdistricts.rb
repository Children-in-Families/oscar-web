class CreateSubdistricts < ActiveRecord::Migration[5.2]
  def change
    create_table :subdistricts do |t|
      t.string :name
      t.references :district, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
