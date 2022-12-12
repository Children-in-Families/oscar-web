class IndexForeignKeysInClientEnrollmentTrackings < ActiveRecord::Migration[5.2]
  def change
    add_index :client_enrollment_trackings, :tracking_id unless index_exists? :client_enrollment_trackings, :tracking_id
  end
end
