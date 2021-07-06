class CaseNotePolicy < ApplicationPolicy
  def edit?
    if Organization.ratanak?
      return true if record.is_editable?
    else
      return true if user.admin?
    end
    DateTime.now.in_time_zone(Time.zone) <= record.created_at + 24.hours
  end

  alias update? edit?

  class Scope < Scope
    def resolve
      scope
    end
  end
end
