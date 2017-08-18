class AddLeaveProgramDefaultValueToProgramStream < ActiveRecord::Migration
  def up
    change_column :program_streams, :exit_program, :jsonb, default: {}
  end

  def down
    change_column :program_streams, :exit_program, :jsonb
  end
end
