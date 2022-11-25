class CreateUserCustomFields < ActiveRecord::Migration[5.2]
  def change
    create_table :user_custom_fields do |t|
      t.text :properties
      t.references :user, index: true, foreign_key: true
      t.references :custom_field, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
