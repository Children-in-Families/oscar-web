class CreateCustomFieldPermissions < ActiveRecord::Migration
  def change
    create_table :custom_field_permissions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :custom_field, index: true, foreign_key: true
      t.boolean :readable, default: true
      t.boolean :editable, default: true

      t.timestamps null: false
    end
  end
end
