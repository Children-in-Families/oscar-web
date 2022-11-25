class CreateProgramStreams < ActiveRecord::Migration[5.2]
  def change
    create_table :program_streams do |t|
      t.string :name
      t.text :description
      t.jsonb :rules, default: {}
      t.jsonb :enrollment, default: {}
      t.jsonb :tracking, default: {}
      t.jsonb :exit_program, default: {}

      t.timestamps null: false
    end
  end
end
