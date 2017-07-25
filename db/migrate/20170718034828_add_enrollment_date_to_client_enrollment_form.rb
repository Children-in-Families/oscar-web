class AddEnrollmentDateToClientEnrollmentForm < ActiveRecord::Migration
  def change
    add_column :client_enrollments, :enrollment_date, :date
  end
end
