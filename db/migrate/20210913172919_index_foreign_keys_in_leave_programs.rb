class IndexForeignKeysInLeavePrograms < ActiveRecord::Migration[5.2]
  def change
    add_index :leave_programs, :program_stream_id unless index_exists? :leave_programs, :program_stream_id
  end
end
