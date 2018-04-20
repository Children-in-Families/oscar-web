class ExitNgo < ActiveRecord::Base
  belongs_to :client

  EXIT_REASONS = ['Client is/moved outside NGO target area (within Cambodia)', 'Client is/moved outside NGO target area (International)', 'Client refused service', 'Client does not meet / no longer meets service criteria', 'Client died', 'Client does not require / no longer requires support', 'Agency lacks sufficient resources', 'Other']

  scope :most_recents, -> { order(created_at: :desc) }

  validates :exit_circumstance, :exit_date, :exit_note, presence: true

  after_create :update_client_status

  private

  def update_client_status
    client.status = 'Exited'
    client.save(validate: false)
  end
end
