class AddExpectedDateToTasks < ActiveRecord::Migration[5.2]
  def change
    rename_column :tasks, :completion_date, :expected_date
    add_column :tasks, :completion_date, :datetime
  end
end
