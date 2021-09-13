class IndexForeignKeysInLeavePrograms < ActiveRecord::Migration
  def change
    add_index :leave_programs, :program_stream_id
  end
end
