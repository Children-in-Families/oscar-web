class CreateFormBuilderAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :form_builder_attachments do |t|
      t.string :name, default: ''
      t.jsonb :file, default: []
      t.string :form_buildable_type
      t.integer :form_buildable_id

      t.timestamps null: false
    end
  end
end
