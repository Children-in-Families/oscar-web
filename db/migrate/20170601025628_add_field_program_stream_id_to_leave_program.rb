class AddFieldProgramStreamIdToLeaveProgram < ActiveRecord::Migration
  def change
    add_column :leave_programs, :program_stream_id, :integer
  end
end
