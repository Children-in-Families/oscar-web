class AddDefaultFieldToClientEnrollment < ActiveRecord::Migration[5.2]
  def up
    change_column :client_enrollments, :properties, :jsonb, default: {}
  end

  def down
    change_column :client_enrollments, :properties, :jsonb
  end
end
