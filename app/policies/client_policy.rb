class ClientPolicy < ApplicationPolicy
  def create?
    record.status != 'Exited'
  end

  def show?(*field_names)
    return true if field_names.blank?
    field = field_names.first

    field_setting = field_settings.find{ |field_setting| field_setting.name == field }

    field_setting.present? ? field_setting.visible? : true
  end
end
