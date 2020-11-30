class FamilyPolicy < ApplicationPolicy
  def create?
    record.status != 'Exited'
  end

  def show?(*field_names)
    return true if field_names.blank?
    field = field_names.first.to_s

    return false if field.in?(%w(member_count member_count_)) && Organization.brc?

    field_setting = field_settings.find{ |field_setting| (field_setting.name == field || field_setting.name == "#{field}_id") && field_setting.klass_name == 'family' }

    field_setting.present? ? (field_setting.required? || field_setting.visible?) : true
  end
end
