class SharedClient < ActiveRecord::Base
  belongs_to :client

  validates :referred_to, :origin_ngo, :fields, :referral_reason, presence: true

  # use after_save for testing, once it is fine, the callback should be after_create
  after_save :notify_admin_of_referred_to

  private

  def notify_admin_of_referred_to
    task = SharedClientNotification.new
    task.notify_admins(self.id, self.referred_from)
  end
end
