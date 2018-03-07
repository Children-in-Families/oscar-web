class CustomFieldPropertyPolicy < ApplicationPolicy
  def new?
    true if record.custom_formable_type != 'Client'
    record.custom_formable.status != 'Exited'
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

  def destroy?
    new?
  end
end