class AddTrackingIdToClientEnrollmentTracking < ActiveRecord::Migration
  def change
    add_column :client_enrollment_trackings, :tracking_id, :integer
  end
end
