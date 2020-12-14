class ExitNgo < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid double_tap_destroys_fully: true

  belongs_to :client, with_deleted: true
  belongs_to :rejectable, polymorphic: true, with_deleted: true

  alias_attribute :new_date, :exit_date

  EXIT_REASONS = ['Client is/moved outside NGO target area (within Cambodia)', 'Client is/moved outside NGO target area (International)', 'Client refused service', 'Client does not meet / no longer meets service criteria', 'Client died', 'Client does not require / no longer requires support', 'Agency lacks sufficient resources', 'Other']
  FAMILY_EXIT_REASONS = ['Family is/moved outside NGO target area (within Cambodia)', 'Family is/moved outside NGO target area (International)', 'Family refused service', 'Family does not meet / no longer meets service criteria', 'Family died', 'Family does not require / no longer requires support', 'Agency lacks sufficient resources', 'Other']

  scope :most_recents, -> { order(created_at: :desc) }

  validates :exit_circumstance, :exit_date, :exit_note, :exit_reasons, presence: true

  after_create :update_entity_status
  after_save :create_exit_ngo_history

  def attached_to_family?
    rejectable_type == 'Family'
  end

  private

  def update_entity_status
    entity = client.present? ? client : rejectable
    entity.status = 'Exited'
    entity.save(validate: false)
  end

  def create_exit_ngo_history
    ExitNgoHistory.initial(self)
  end
end
