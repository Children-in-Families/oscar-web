class SharedClientNotification
  def initialize
  end

  def notify_admins(shared_client_id, referred_from)
    SharedClientWorker.perform_async(shared_client_id, referred_from)
  end
end
