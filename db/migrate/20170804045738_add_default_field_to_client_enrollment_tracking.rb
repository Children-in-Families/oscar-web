class AddDefaultFieldToClientEnrollmentTracking < ActiveRecord::Migration
  def change
    change_column :client_enrollment_trackings, :properties, :jsonb, default: {}
  end
end
