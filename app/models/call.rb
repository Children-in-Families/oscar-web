class Call < ActiveRecord::Base
  FIELDS = %w( phone_call_id call_type start_datetime start_time information_provided answered_call called_before requested_update )
  TYPES  = [
            "New Referral: Case Action Required", "New Referral: Case Action NOT Required",
            "Providing Update", "Phone Counselling",
            "Seeking Information", "Spam Call", "Wrong Number"
          ].freeze

  belongs_to :referee
  belongs_to :receiving_staff, class_name: 'User', foreign_key: 'receiving_staff_id'

  has_many :hotlines, dependent: :destroy
  has_many :clients, through: :hotlines
  has_many :call_protection_concerns, dependent: :destroy
  has_many :protection_concerns, through: :call_protection_concerns
  has_many :call_necessities, dependent: :destroy
  has_many :necessities, through: :call_necessities

  scope :most_recents, -> { order(date_of_call: :desc) }

  after_save :set_phone_call_id, if: -> { phone_call_id.blank? }

  validates :receiving_staff_id, :date_of_call, :start_datetime, presence: true
  validates :called_before, :answered_call, :childsafe_agent, inclusion: { in: [true, false] }
  validates :call_type, presence: true, inclusion: { in: TYPES }
  validates :information_provided, presence: true, if: :seeking_information?

  def seeking_information?
    call_type == "Seeking Information"
  end

  def case_action_not_required?
    call_type == "New Referral: Case Action NOT Required"
  end

  def spam?
    call_type == "Spam Call"
  end

  def wrong_number?
    call_type == "Wrong Number"
  end

  def no_client_attached?
    seeking_information? || spam? || wrong_number?
  end

  def self.mapping_query_field(query_string)
    query_string = query_string.gsub(/'true'/, 'true')
    query_string = query_string.gsub(/childsafe_agent = 'false'/, 'childsafe_agent IS NULL OR childsafe_agent is false')
    query_string = query_string.gsub(/called_before = 'false'/, 'called_before IS NULL OR called_before is false')
    query_string = query_string.gsub(/answered_call = 'false'/, 'answered_call IS NULL OR answered_call is false')
    query_string = query_string.gsub(/'start_time'/, "DATE_PART('hour', start_datetime)")
  end

  private

  def set_phone_call_id
    id      = self.id.to_s.rjust(4, '0')
    date    = self.date_of_call.strftime('%Y%m%d')
    call_id = "#{date}-#{id}"
    self.update_columns(phone_call_id: call_id)
  end
end
