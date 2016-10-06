class CreateProgressNoteType < ActiveRecord::Migration
  def change
    create_table :progress_note_types do |t|
      t.string :note_type, default: ''
      t.timestamps
    end
  end
end
