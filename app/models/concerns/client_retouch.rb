module ClientRetouch
  extend ActiveSupport::Concern

  included do
    after_commit :touch_client, on: [:create, :update]
  end

  def touch_client
    client.touch
  end
end
