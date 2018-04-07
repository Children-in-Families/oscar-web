class CreateExitNgo < ActiveRecord::Migration
  def change
    create_table :exit_ngos do |t|
      t.references :client, index: true, foreign_key: true
      t.string :exit_circumstance, default: ''
      t.string :other_info_of_exit, default: ''
      t.string :exit_reasons, array: true, default: []
      t.text :exit_note, default: ''
      t.date :exit_date
      t.timestamps
    end
  end
end
