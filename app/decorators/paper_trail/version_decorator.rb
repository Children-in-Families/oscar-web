class PaperTrail::VersionDecorator < Draper::Decorator
  delegate_all

  def whodunnit
    user = User.find_by(id: object.whodunnit)
    user.present? ? user.name : object.whodunnit
  end

  def event
    object.event == 'destroy' ? 'delete' : object.event
  end

  def client_item_type?
    item_type == 'Client'
  end

  def event_formated
    I18n.t(".shared.version_type.common.#{event}")
  end
end
