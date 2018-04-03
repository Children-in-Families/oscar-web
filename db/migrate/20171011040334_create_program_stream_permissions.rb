class CreateProgramStreamPermissions < ActiveRecord::Migration
  def change
    create_table :program_stream_permissions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :program_stream, index: true, foreign_key: true
      t.boolean :readable, default: false
      t.boolean :editable, default: false

      t.timestamps null: false
    end
  end
end