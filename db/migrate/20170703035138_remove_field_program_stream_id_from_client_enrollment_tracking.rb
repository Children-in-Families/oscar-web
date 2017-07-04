class RemoveFieldProgramStreamIdFromClientEnrollmentTracking < ActiveRecord::Migration
  def change
    remove_column :client_enrollment_trackings, :program_stream_id, :integer
  end
end
