class AddFieldDisabledFutureCompletionDateToSettings < ActiveRecord::Migration[5.2]
  def change
    add_column :settings, :disabled_future_completion_date, :boolean, default: false
  end
end
