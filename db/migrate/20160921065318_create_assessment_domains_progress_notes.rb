class CreateAssessmentDomainsProgressNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :assessment_domains_progress_notes do |t|
      t.references :assessment_domain, index: true, foreign_key: true
      t.references :progress_note, index: true, foreign_key: true
      t.timestamps
    end
  end
end
