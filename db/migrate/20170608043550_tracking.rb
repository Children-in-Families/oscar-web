class Tracking < ActiveRecord::Migration[5.2]
  def change
    create_table :trackings do |t|
      t.string :name, default: ''
      t.jsonb :fields
      t.string :frequency, default: ''
      t.integer :time_of_frequency
      t.references :program_stream, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
