class AddFieldDisabledTaskDateFieldToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :disabled_task_date_field, :boolean, default: true
  end
end
