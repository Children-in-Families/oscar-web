class CreateProgramStreamServices < ActiveRecord::Migration[5.2]
  def change
    create_table :program_stream_services do |t|
      t.datetime :deleted_at
      t.references :program_stream, index: true, foreign_key: true
      t.references :service, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :program_stream_services, :deleted_at
  end
end
