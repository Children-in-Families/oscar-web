class RemoveFieldProgramStreamIdFromClientEnrollmentTracking < ActiveRecord::Migration[5.2]
  def change
    remove_column :client_enrollment_trackings, :program_stream_id, :integer
  end
end
