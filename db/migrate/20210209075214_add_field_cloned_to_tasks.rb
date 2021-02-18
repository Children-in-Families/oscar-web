class AddFieldClonedToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :cloned, :boolean, default: false
  end
end
