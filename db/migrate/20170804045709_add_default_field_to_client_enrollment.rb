class AddDefaultFieldToClientEnrollment < ActiveRecord::Migration
  def up
    change_column :client_enrollments, :properties, :jsonb, default: {}
  end

  def down
    change_column :client_enrollments, :properties, :jsonb
  end
end
