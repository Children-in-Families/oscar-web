class EmergencyCareCaseDecorator < Draper::Decorator
  delegate_all

  def client_name
    model.client.name if model.client
  end
end
