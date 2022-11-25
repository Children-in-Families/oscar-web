class AddFieldDisabledTaskDateFieldToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :disabled_task_date_field, :boolean, default: true
  end
end
