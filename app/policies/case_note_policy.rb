class CaseNotePolicy < ApplicationPolicy
  def edit?
    return true if user.admin?
    if Organization.ratanak?
      record.is_editable? ? true : false
    else
      DateTime.now.in_time_zone(Time.zone) <= record.created_at + 24.hours
    end
  end

  alias create? edit?
  alias update? edit?

  class Scope < Scope
    def resolve
      scope
    end
  end
end
