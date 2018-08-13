class CreateCommune < ActiveRecord::Migration
  def change
    create_table :communes do |t|
      t.string :code, default: ''
      t.string :name_kh, default: ''
      t.string :name_en, default: ''
      t.references :district, index: true, foreign_key: true

      t.timestamps
    end
  end
end
