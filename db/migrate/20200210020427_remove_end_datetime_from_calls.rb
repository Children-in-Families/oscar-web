class RemoveEndDatetimeFromCalls < ActiveRecord::Migration[5.2]
  def change
    remove_column :calls, :end_datetime, :datetime
  end
end
