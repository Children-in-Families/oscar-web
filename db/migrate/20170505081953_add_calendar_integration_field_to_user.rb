class AddCalendarIntegrationFieldToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :calendar_integration, :boolean, default: false
  end
end
