class CreateClientEnrollments < ActiveRecord::Migration[5.2]
  def change
    create_table :client_enrollments do |t|
      t.jsonb :properties
      t.string :status, default: 'Active'
      t.references :client, index: true, foreign_key: true
      t.references :program_stream, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
