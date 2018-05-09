class SharedClientNotification
  def initialize
  end

  def notify_admins(shared_client_id, origin_ngo)
    SharedClientWorker.perform_async(shared_client_id, origin_ngo)
  end
end
