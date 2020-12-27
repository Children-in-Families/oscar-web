class AddGoalToTasks < ActiveRecord::Migration
  def change
    add_reference :tasks, :goal, index: true, foreign_key: true
  end
end
