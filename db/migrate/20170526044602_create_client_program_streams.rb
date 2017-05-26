class CreateClientProgramStreams < ActiveRecord::Migration
  def change
    create_table :client_program_streams do |t|
      t.integer :client_id
      t.integer :program_stream_id

      t.timestamps null: false
    end
  end
end
