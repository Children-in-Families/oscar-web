class AddExitDateToLeaveProgram < ActiveRecord::Migration
  def change
    add_column :leave_programs, :exit_date, :date
  end
end
