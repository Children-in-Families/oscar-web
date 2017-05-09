class AddCalendarIntegrationFieldToUser < ActiveRecord::Migration
  def change
    add_column :users, :calendar_integration, :boolean, default: false
  end
end
