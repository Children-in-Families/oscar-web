class AddFieldDisableProgressNoteAndNextStepToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :disabled_progress_note_and_next_step, :boolean, default: false
  end
end
