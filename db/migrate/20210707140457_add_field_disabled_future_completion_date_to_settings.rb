class AddFieldDisabledFutureCompletionDateToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :disabled_future_completion_date, :boolean, default: false
  end
end
