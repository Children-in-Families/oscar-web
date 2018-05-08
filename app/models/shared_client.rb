class SharedClient < ActiveRecord::Base
  belongs_to :client

  validates :destination_ngo, :origin_ngo, :fields, :referral_reason, presence: true

  # use after_save for testing, once it is fine, the callback should be after_create
  after_save :notify_admin_of_destination_ngo

  private

  def notify_admin_of_destination_ngo
    task = SharedClientNotification.new
    # binding.pry
    task.notify_admins(self.id, self.origin_ngo)
  end
end
