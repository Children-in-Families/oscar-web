class FamilyMemberPolicy < ApplicationPolicy
  def show?(*field_names)
    return true if field_names.blank?
    field = field_names.first.to_s

    field_setting = field_settings.find{ |field_setting| field_setting.name == field && field_setting.klass_name == 'family_member' }

    field_setting.present? ? (field_setting.required? || field_setting.visible?) : true
  end
end
