class AddDeletedAtToLeaveProgram < ActiveRecord::Migration
  def change
    add_column :leave_programs, :deleted_at, :datetime
    add_index :leave_programs, :deleted_at
  end
end
