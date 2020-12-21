class CreateCustomFieldProperties < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_field_properties do |t|
      t.jsonb :properties, default: {}
      t.string :custom_formable_type
      t.integer :custom_formable_id
      t.references :custom_field, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
