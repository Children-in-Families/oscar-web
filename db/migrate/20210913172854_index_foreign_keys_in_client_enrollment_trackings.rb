class IndexForeignKeysInClientEnrollmentTrackings < ActiveRecord::Migration
  def change
    add_index :client_enrollment_trackings, :tracking_id
  end
end
