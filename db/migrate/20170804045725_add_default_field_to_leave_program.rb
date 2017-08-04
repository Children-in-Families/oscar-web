class AddDefaultFieldToLeaveProgram < ActiveRecord::Migration
  def change
    change_column :leave_programs, :properties, :jsonb, default: {}
  end
end
