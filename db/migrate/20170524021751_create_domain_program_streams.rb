class CreateDomainProgramStreams < ActiveRecord::Migration
  def change
    create_table :domain_program_streams do |t|
      t.integer :program_stream_id
      t.integer :domain_id

      t.timestamps null: false
    end
  end
end
