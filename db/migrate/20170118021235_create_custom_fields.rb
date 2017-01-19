class CreateCustomFields < ActiveRecord::Migration
  def change
    create_table :custom_fields do |t|
      t.string :entity_name
      t.string :fields

      t.timestamps null: false
    end
  end
end
