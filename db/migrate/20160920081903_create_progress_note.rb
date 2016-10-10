class CreateProgressNote < ActiveRecord::Migration
  def change
    create_table :progress_notes do |t|
      t.date :date
      t.string :other_location, default: ''
      t.text :response,         default: ''
      t.text :additional_note,  default: ''
      t.references :client, index: true, foreign_key: true
      t.references :progress_note_type, index: true, foreign_key: true
      t.references :location, index: true, foreign_key: true
      t.references :material, index: true, foreign_key: true

      t.timestamps
    end
  end
end
