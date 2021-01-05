class CreateLeavePrograms < ActiveRecord::Migration[5.2]
  def change
    create_table :leave_programs do |t|
      t.jsonb :properties
      t.references :client_enrollment, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
