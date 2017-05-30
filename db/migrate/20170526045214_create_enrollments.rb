class CreateEnrollments < ActiveRecord::Migration
  def change
    create_table :enrollments do |t|
      t.jsonb :properties
      t.references :client_program_stream, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
