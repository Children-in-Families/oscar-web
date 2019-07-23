class DropInterventionsProgressNoteTable < ActiveRecord::Migration
  def up
    drop_table :interventions_progress_notes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
