class AddFieldClonedToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :cloned, :boolean, default: false
  end
end
