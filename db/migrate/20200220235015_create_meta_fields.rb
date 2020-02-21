class CreateMetaFields < ActiveRecord::Migration
  def change
    create_table :meta_fields do |t|
      t.string :field_name
      t.string :field_type
      t.string :hidden
      t.string :required
      t.string :label

      t.timestamps null: false
    end
  end
end
