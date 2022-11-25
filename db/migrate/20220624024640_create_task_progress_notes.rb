class CreateTaskProgressNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :task_progress_notes do |t|
      t.text :progress_note
      t.integer :task_id

      t.timestamps null: false
    end
    add_index :task_progress_notes, :task_id
  end
end
