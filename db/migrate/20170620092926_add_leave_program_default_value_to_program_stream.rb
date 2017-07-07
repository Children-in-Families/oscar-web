class AddLeaveProgramDefaultValueToProgramStream < ActiveRecord::Migration
  def up
    add_column :program_streams, :exit_program, :jsonb, default: {}
  end

  def down
    remove_column :program_streams, :exit_program, :jsonb
  end
end
