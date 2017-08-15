class AddDefaultFieldToClientEnrollment < ActiveRecord::Migration
  def up
    add_column :client_enrollments, :properties, :jsonb, default: {}
  end

  def down
    remove_column :client_enrollments, :properties, :jsonb, default: {}
  end
end
