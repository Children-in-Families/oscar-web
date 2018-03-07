class AssessmentPolicy < ApplicationPolicy
  def new?
    record.client.status != 'Exited'
  end

  def create?
    new?
  end

  def edit?
    new?
  end

  def update?
    new?
  end
end
