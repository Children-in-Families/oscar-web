module ClientRetouch
  extend ActiveSupport::Concern

  included do
    after_commit :touch_client, on: [:create, :update]
  end

  def touch_client
    if self.class.name == 'ProgramStream'
      clients.joins(:referrals).where(referrals: { ngo_name: 'MoSVY External System' }).each(&:touch)
    else
      client&.touch
    end
  end
end
