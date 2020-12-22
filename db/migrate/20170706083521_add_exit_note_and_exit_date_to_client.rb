class AddExitNoteAndExitDateToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :exit_note, :text, default: ''
    add_column :clients, :exit_date, :date
  end
end
