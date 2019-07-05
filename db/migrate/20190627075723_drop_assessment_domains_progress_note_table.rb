class DropAssessmentDomainsProgressNoteTable < ActiveRecord::Migration
  def up
    drop_table :assessment_domains_progress_notes
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
