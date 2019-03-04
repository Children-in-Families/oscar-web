class AddDeletedToClientEnrollment < ActiveRecord::Migration
  def change
    add_column :client_enrollments, :deleted_at, :datetime
    add_index :client_enrollments, :deleted_at
  end
end
