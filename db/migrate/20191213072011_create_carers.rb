class CreateCarers < ActiveRecord::Migration[5.2]
  def change
    create_table :carers do |t|
      t.string :address_type, default: ''
      t.string :current_address, default: ''
      t.string :email, default: ''
      t.string :gender, default: ''
      t.string :house_number, default: ''
      t.string :outside_address, default: ''
      t.string :street_number, default: ''
      t.string :client_relationship, default: ''
      t.boolean :outside, default: false
      t.references :province, index: true, foreign_key: true
      t.references :district, index: true, foreign_key: true
      t.references :commune, index: true, foreign_key: true
      t.references :village, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
