class AddDefaultFieldToClientEnrollment < ActiveRecord::Migration
  def change
    change_column :client_enrollments, :properties, :jsonb, default: {}
  end
end
