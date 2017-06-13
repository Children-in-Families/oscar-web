class ClientEnrollmentPolicy < ApplicationPolicy  
  def update?
    record.status == 'Active'
  end
end