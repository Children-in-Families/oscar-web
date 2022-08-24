module ClientRetouch
  extend ActiveSupport::Concern

  included do
    after_commit :touch_client, on: [:create, :update]
  end

  def touch_client
    if self.class.name == 'ProgramStream'
      clients.joins(:referrals).where(referrals: { ngo_name: 'MoSVY External System' }).each{ |client| client.update_column(:updated_at, Time.now) }
    else
      if client.present?
        client.update_column(:updated_at, Time.now)
      else
        update_column(:updated_at, Time.now)
      end
    end
  end
end
