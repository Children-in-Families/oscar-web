class RenameTrackingTableToClientTracking < ActiveRecord::Migration
  def change
    rename_table :trackings, :client_enrollment_trackings
  end
end
