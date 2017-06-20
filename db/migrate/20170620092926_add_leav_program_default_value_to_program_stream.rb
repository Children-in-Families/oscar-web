class AddLeavProgramDefaultValueToProgramStream < ActiveRecord::Migration
  def change
    change_column :program_streams, :exit_program, :jsonb, default: {}
  end
end
