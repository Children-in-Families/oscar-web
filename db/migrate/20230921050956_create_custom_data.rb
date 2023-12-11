class CreateCustomData < ActiveRecord::Migration
  def change
    create_table :custom_data do |t|
      t.jsonb :fields, default: {}

      t.timestamps null: false
    end
  end
end
