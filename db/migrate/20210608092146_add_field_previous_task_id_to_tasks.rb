class AddFieldPreviousTaskIdToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :previous_id, :integer
    add_index :tasks, :previous_id
  end
end
