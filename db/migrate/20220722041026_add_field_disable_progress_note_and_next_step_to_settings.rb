class AddFieldDisableProgressNoteAndNextStepToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :required_case_note_note, :boolean, default: true
  end
end
