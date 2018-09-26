class EnterNgo < ActiveRecord::Base
  has_paper_trail

  belongs_to :client

  alias_attribute :new_date, :accepted_date

  has_many :enter_ngo_users, dependent: :destroy
  has_many :users, through: :enter_ngo_users

  scope :most_recents, -> { order(created_at: :desc) }

  validates :accepted_date, presence: true
  validates :user_ids, presence: true, on: :create, if: Proc.new { |e| e.client.present? && e.client.exit_ngo? }

  after_create :update_client_status
  after_save :create_enter_ngo_history

  private

  def update_client_status
    client.status = 'Accepted'
    if user_ids.any?
      client.user_ids = self.user_ids
    end
    client.save(validate: false)
  end

  def create_enter_ngo_history
    EnterNgoHistory.initial(self)
  end
end
