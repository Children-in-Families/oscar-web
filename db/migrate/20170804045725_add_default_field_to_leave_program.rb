class AddDefaultFieldToLeaveProgram < ActiveRecord::Migration
  def up
    change_column :leave_programs, :properties, :jsonb, default: {}
  end

  def down
    change_column :leave_programs, :properties, :jsonb
  end
end
