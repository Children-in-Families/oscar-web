class AddDefaultFieldToLeaveProgram < ActiveRecord::Migration
  def up
    add_column :leave_programs, :properties, :jsonb, default: {}
  end

  def down
    remove_column :leave_programs, :properties, :jsonb, default: {}
  end
end
