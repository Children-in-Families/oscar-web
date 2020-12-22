class AddTrackingIdToClientEnrollmentTracking < ActiveRecord::Migration[5.2]
  def change
    add_column :client_enrollment_trackings, :tracking_id, :integer
  end
end
