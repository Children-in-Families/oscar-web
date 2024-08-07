class CreateCaseNotesCustomFieldProperties < ActiveRecord::Migration
  def change
    create_table :case_notes_custom_field_properties do |t|
      t.references :case_note, index: true, foreign_key: true
      t.references :custom_field, index: { name: 'index_custom_field_properties_on_case_notes_custom_field_id' }, foreign_key: { to_table: :case_notes_custom_field }
      t.jsonb :properties, default: {}

      t.timestamps null: false
    end
  end
end
