class RenameTrackingTableToClientTracking < ActiveRecord::Migration[5.2]
  def change
    rename_table :trackings, :client_enrollment_trackings
  end
end
