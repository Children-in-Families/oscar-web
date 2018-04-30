class CreateQuantitativeTypePermissions < ActiveRecord::Migration
  def change
    create_table :quantitative_type_permissions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :quantitative_type, index: true, foreign_key: true
      t.boolean :readable, default: true
      t.boolean :editable, default: true

      t.timestamps null: false
    end
  end
end
