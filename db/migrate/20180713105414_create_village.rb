class CreateVillage < ActiveRecord::Migration[5.2]
  def change
    create_table :villages do |t|
      t.string :code, default: ''
      t.string :name_kh, default: ''
      t.string :name_en, default: ''
      t.references :commune, index: true, foreign_key: true

      t.timestamps
    end
  end
end
