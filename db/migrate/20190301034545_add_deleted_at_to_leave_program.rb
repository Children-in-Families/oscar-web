class AddDeletedAtToLeaveProgram < ActiveRecord::Migration[5.2]
  def change
    add_column :leave_programs, :deleted_at, :datetime
    add_index :leave_programs, :deleted_at
  end
end
