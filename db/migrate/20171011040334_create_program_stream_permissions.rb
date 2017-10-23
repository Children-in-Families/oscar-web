class CreateProgramStreamPermissions < ActiveRecord::Migration
  def change
    create_table :program_stream_permissions do |t|
      t.references :user, index: true, foreign_key: true
      t.references :program_stream, index: true, foreign_key: true
      t.boolean :readable, default: true
      t.boolean :editable, default: true

      t.timestamps null: false
    end
  end
end
g