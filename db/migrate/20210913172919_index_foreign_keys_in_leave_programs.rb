class IndexForeignKeysInLeavePrograms < ActiveRecord::Migration[5.2]
  def change
    add_index :leave_programs, :program_stream_id
  end
end
