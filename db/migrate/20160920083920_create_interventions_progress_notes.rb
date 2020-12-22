class CreateInterventionsProgressNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :interventions_progress_notes do |t|
      t.references :progress_note, index: true, foreign_key: true
      t.references :intervention, index: true, foreign_key: true

      t.timestamps
    end
  end
end
