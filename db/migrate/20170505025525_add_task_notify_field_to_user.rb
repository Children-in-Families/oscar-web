class AddTaskNotifyFieldToUser < ActiveRecord::Migration
  def change
    add_column :users, :task_notify, :boolean, default: true
  end
end
