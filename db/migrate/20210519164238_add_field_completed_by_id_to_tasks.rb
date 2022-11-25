class AddFieldCompletedByIdToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :completed_by_id, :integer
    add_index :tasks, :completed_by_id
  end
end
