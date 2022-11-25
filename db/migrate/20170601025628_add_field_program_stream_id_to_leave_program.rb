class AddFieldProgramStreamIdToLeaveProgram < ActiveRecord::Migration[5.2]
  def change
    add_column :leave_programs, :program_stream_id, :integer
  end
end
