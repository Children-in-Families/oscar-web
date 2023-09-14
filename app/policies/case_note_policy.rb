class CaseNotePolicy < ApplicationPolicy
  def edit?
    return true if user.admin?

    if Organization.ratanak?
      record.is_editable? ? true : false
    elsif record.draft?
      true
    else
      DateTime.now.in_time_zone(Time.zone) <= (record.try(:created_at) || Date.today) + 24.hours
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
