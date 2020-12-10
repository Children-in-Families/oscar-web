class EnterNgo < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid double_tap_destroys_fully: true

  belongs_to :client, with_deleted: true
  belongs_to :acceptable, polymorphic: true, with_deleted: true

  alias_attribute :new_date, :accepted_date

  has_many :enter_ngo_users, dependent: :destroy
  has_many :users, through: :enter_ngo_users

  scope :most_recents, -> { order(created_at: :desc) }
  scope :attached_with_clients, -> { where.not(client_id: nil) }

  validates :accepted_date, presence: true
  validates :user_ids, presence: true, on: :create, if: Proc.new { |e| (e.client.present? && e.client.exit_ngo?) || (e.acceptable.present? && e.acceptable.exit_ngo?) }

  after_create :update_entity_status
  after_save :create_enter_ngo_history

  private

  def update_entity_status
    entity = client.present? ? client : acceptable
    entity.status = 'Accepted'
    if user_ids.any?
      entity.user_ids = self.user_ids
    end
    entity.save(validate: false)
  end

  def create_enter_ngo_history
    EnterNgoHistory.initial(self)
  end
end
