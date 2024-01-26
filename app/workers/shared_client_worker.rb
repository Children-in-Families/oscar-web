class SharedClientWorker
  include Sidekiq::Worker

  def perform(client_id, tenant)
    Organization.switch_to tenant

    client = Client.find_by(id: client_id)
    return if client.blank?

    client.create_or_update_shared_client
  end
end
