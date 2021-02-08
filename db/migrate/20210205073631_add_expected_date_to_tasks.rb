class AddExpectedDateToTasks < ActiveRecord::Migration
  def change
    rename_column :tasks, :completion_date, :expected_date
    add_column :tasks, :completion_date, :datetime
  end
end
