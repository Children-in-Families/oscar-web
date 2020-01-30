class Call < ActiveRecord::Base
  FIELDS = %w( phone_call_id call_type start_datetime end_datetime start_time end_time information_provided )
  TYPES  = [
            "New Referral: Case Action Required", "New Referral: Case Action NOT Required",
            "Providing Update", "Phone Counselling",
            "Seeking Information", "Spam Call", "Wrong Number"
          ].freeze

  belongs_to :referee
  belongs_to :receiving_staff, class_name: 'User', foreign_key: 'receiving_staff_id'

  has_many :hotlines, dependent: :destroy
  has_many :clients, through: :hotlines

  scope :most_recents, -> { order(date_of_call: :desc) }

  after_save :set_phone_call_id, if: -> { phone_call_id.blank? }

  validates :receiving_staff_id, :date_of_call, :start_datetime, :end_datetime, presence: true
  validates :call_type, presence: true, inclusion: { in: TYPES }
  validates :information_provided, presence: true, if: :no_client_attached?

  def no_client_attached?
    call_type === "Seeking Information" || call_type === "Spam Call" || call_type === "Wrong Number"
  end

  def case_action_not_required?
    call_type == "New Referral: Case Action NOT Required"
  end

  private

  def set_phone_call_id
    id      = self.id.to_s.rjust(4, '0')
    date    = self.date_of_call.strftime('%Y%m%d')
    call_id = "#{date}-#{id}"
    self.update_columns(phone_call_id: call_id)
  end
end
