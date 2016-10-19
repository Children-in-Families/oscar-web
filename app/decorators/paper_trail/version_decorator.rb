 class PaperTrail::VersionDecorator < Draper::Decorator
  delegate_all

  def whodunnit
    User.find(object.whodunnit).name
  end

  def event
    object.event == 'destroy' ? 'delete' : object.event
  end

  def client_item_type?
    item_type == 'Client'
  end

  def event_formated
    I18n.t(".shared.version.#{event}")
  end
end
