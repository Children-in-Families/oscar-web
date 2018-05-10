class SharedClientWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'send_email'

  def perform(shared_client_id, referred_from)
    SharedClientMailer.notify_of_shared_client(shared_client_id, referred_from).deliver_now
  end
end
