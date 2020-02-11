class RemoveEndDatetimeFromCalls < ActiveRecord::Migration
  def change
    remove_column :calls, :end_datetime, :datetime
  end
end
