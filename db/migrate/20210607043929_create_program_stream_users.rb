class CreateProgramStreamUsers < ActiveRecord::Migration
  def change
    create_table :program_stream_users do |t|
      t.integer :user_id
      t.integer :program_stream_id

      t.timestamps null: false
    end
    add_index :program_stream_users, :user_id
    add_index :program_stream_users, :program_stream_id
  end
end
