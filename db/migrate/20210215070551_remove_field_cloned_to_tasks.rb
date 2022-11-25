class RemoveFieldClonedToTasks < ActiveRecord::Migration[5.2]
  def change
    remove_column :tasks, :cloned, :boolean
  end
end
