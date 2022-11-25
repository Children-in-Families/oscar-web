class AddFieldPreviousTaskIdToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :previous_id, :integer
    add_index :tasks, :previous_id
  end
end
