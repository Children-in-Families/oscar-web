class CreateCustomFields < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_fields do |t|
      t.string :entity_name, default: ''
      t.text :fields, default: ''

      t.timestamps null: false
    end
  end
end
