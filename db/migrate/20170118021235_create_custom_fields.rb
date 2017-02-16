class CreateCustomFields < ActiveRecord::Migration
  def change
    create_table :custom_fields do |t|
      t.string :entity_name, default: ''
      t.text :fields, default: ''

      t.timestamps null: false
    end
  end
end
