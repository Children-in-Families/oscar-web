class AddEnrollmentReferenceToLeaveProgram < ActiveRecord::Migration[5.2]
  def change
    add_reference :leave_programs, :enrollment, index: true, foreign_key: true
  end
end
