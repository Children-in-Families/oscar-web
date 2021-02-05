class AddExpectedDateToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :expected_date, :datetime
  end
end
