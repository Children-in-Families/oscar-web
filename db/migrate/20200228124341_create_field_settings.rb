class CreateFieldSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :field_settings do |t|
      t.string :name, null: false
      t.string :label, null: false
      t.string :group, null: false
      t.boolean :hidden, default: false

      t.timestamps null: false
    end
  end
end
