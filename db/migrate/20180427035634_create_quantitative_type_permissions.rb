class CreateQuantitativeTypePermissions < ActiveRecord::Migration
  def change
    create_table :quantitative_type_permissions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :quantitative_type, index: true, foreign_key: true
      t.boolean :readable, default: false
      t.boolean :editable, default: false

      t.timestamps null: false
    end
  end
end
