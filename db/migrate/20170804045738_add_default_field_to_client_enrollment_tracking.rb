class AddDefaultFieldToClientEnrollmentTracking < ActiveRecord::Migration
  def up
    change_column :client_enrollment_trackings, :properties, :jsonb, default: {}
  end

  def down
    change_column :client_enrollment_trackings, :properties, :jsonb
  end
end
