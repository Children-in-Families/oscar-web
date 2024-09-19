class CreateCaseNotesCustomFields < ActiveRecord::Migration
  def change
    create_table :case_notes_custom_fields do |t|
      t.datetime :deleted_at
      t.jsonb :fields

      t.timestamps null: false
    end
  end
end
