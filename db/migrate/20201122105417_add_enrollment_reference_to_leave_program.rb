class AddEnrollmentReferenceToLeaveProgram < ActiveRecord::Migration
  def change
    add_reference :leave_programs, :enrollment, index: true, foreign_key: true
  end
end
