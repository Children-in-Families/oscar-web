class DropInterventionsProgressNoteTable < ActiveRecord::Migration[5.2]
  def up
    drop_table :interventions_progress_notes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
