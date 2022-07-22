class AddFieldDisableProgressNoteAndNextStepToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :required_case_note_note, :boolean, default: true
  end
end
