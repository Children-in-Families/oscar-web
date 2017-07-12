class AddExitNoteAndExitDateToClient < ActiveRecord::Migration
  def change
    add_column :clients, :exit_note, :text, default: ''
    add_column :clients, :exit_date, :date
  end
end
