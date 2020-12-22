class AddExitDateToLeaveProgram < ActiveRecord::Migration[5.2]
  def change
    add_column :leave_programs, :exit_date, :date
  end
end
