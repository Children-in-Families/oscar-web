class AddCustomFormableToCaseNotesCustomFieldProperties < ActiveRecord::Migration
  def change
    add_column :case_notes_custom_field_properties, :custom_formable_id, :integer
    add_column :case_notes_custom_field_properties, :custom_formable_type, :string

    add_index :case_notes_custom_field_properties, [:custom_formable_id, :custom_formable_type], name: 'index_case_notes_custom_field_properties_on_custom_formable'
  end
end
