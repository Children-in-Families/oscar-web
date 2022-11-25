class CreateDistrict < ActiveRecord::Migration[5.2]
  def change
    create_table :districts do |t|
      t.string :name
      t.references :province, index: true, foreign_key: true
    end
  end
end
