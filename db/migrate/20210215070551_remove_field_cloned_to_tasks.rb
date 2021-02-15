class RemoveFieldClonedToTasks < ActiveRecord::Migration
  def change
    remove_column :tasks, :cloned, :boolean
  end
end
