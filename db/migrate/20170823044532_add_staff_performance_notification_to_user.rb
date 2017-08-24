class AddStaffPerformanceNotificationToUser < ActiveRecord::Migration
  def change
    add_column :users, :staff_performance_notification, :boolean, default: true
  end
end
