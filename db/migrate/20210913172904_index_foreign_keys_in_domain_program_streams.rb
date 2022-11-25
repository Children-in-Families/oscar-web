class IndexForeignKeysInDomainProgramStreams < ActiveRecord::Migration[5.2]
  def change
    add_index :domain_program_streams, :domain_id
    add_index :domain_program_streams, :program_stream_id
  end
end
