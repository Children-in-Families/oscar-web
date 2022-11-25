class AddGoalToTasks < ActiveRecord::Migration[5.2]
  def change
    add_reference :tasks, :goal, index: true, foreign_key: true
  end
end
