class CreateCalls < ActiveRecord::Migration[5.2]
  def change
    create_table :calls do |t|
      t.references :referee, index: true, foreign_key: true
      t.string :phone_call_id, default: ''
      t.integer :receiving_staff_id
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.string :call_type, default: ''

      t.timestamps null: false
    end
  end
end
