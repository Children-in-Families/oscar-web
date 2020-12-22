class AddDeletedToClientEnrollment < ActiveRecord::Migration[5.2]
  def change
    add_column :client_enrollments, :deleted_at, :datetime
    add_index :client_enrollments, :deleted_at
  end
end
