class AddDefaultFieldToClientEnrollmentTracking < ActiveRecord::Migration
  def up
    add_column :client_enrollment_trackings, :properties, :jsonb, default: {}
  end

  def down
    remove_column :client_enrollment_trackings, :properties, :jsonb, default: {}
  end
end
