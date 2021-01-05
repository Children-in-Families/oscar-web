class AddDefaultFieldToClientEnrollmentTracking < ActiveRecord::Migration[5.2]
  def up
    change_column :client_enrollment_trackings, :properties, :jsonb, default: {}
  end

  def down
    change_column :client_enrollment_trackings, :properties, :jsonb
  end
end
