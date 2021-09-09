class AddFieldTaskIdToCalendars < ActiveRecord::Migration
  def change
    add_column :calendars, :task_id, :integer
    add_index :calendars, :task_id
  end
end
