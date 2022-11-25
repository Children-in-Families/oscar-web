class CreateEnrollment < ActiveRecord::Migration[5.2]
  def change
    create_table :enrollments do |t|
      t.jsonb :properties, default: {}
      t.string :status, default: 'Active'
      t.date :enrollment_date
      t.datetime :deleted_at
      t.string :programmable_type
      t.integer :programmable_id
      t.references :program_stream, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :enrollments, :deleted_at
  end
end
