class CreateProgressNoteType < ActiveRecord::Migration[5.2]
  def change
    create_table :progress_note_types do |t|
      t.string :note_type, default: ''
      t.timestamps
    end
  end
end
