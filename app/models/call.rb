class Call < ActiveRecord::Base
  include CacheAll

  FIELDS = %w( phone_call_id call_type date_of_call start_datetime information_provided answered_call called_before requested_update childsafe_agent protection_concern_id necessity_id not_a_phone_call brief_note_summary other_more_information)
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
    query_string = query_string.gsub(/not_a_phone_call = 'false'/, 'not_a_phone_call IS NULL OR not_a_phone_call is false')
    query_string = query_string.gsub(/requested_update = 'false'/, 'requested_update IS NULL OR requested_update is false')

    query_string = query_string.gsub(/childsafe_agent = ''/, 'childsafe_agent IS NULL')
    query_string = query_string.gsub(/called_before = ''/, 'called_before IS NULL')
    query_string = query_string.gsub(/answered_call = ''/, 'answered_call IS NULL')
    query_string = query_string.gsub(/not_a_phone_call = ''/, 'not_a_phone_call IS NULL')
    query_string = query_string.gsub(/requested_update = ''/, 'requested_update IS NULL')

    query_string = query_string.gsub(/childsafe_agent != ''/, 'childsafe_agent IS NOT NULL')
    query_string = query_string.gsub(/called_before != ''/, 'called_before IS NOT NULL')
    query_string = query_string.gsub(/answered_call != ''/, 'answered_call IS NOT NULL')
    query_string = query_string.gsub(/not_a_phone_call != ''/, 'not_a_phone_call IS NOT NULL')
    query_string = query_string.gsub(/requested_update != ''/, 'requested_update IS NOT NULL')

    query_string = query_string.gsub(/start_datetime/, "DATE_PART('hour', start_datetime)")
    query_string = query_string.gsub(/necessity_id/, "call_necessities.necessity_id")
    query_string = query_string.gsub(/protection_concern_id/, "call_protection_concerns.protection_concern_id")
  end

  private

  def set_phone_call_id
    id      = self.id.to_s.rjust(4, '0')
    date    = self.date_of_call.strftime('%Y%m%d')
    call_id = "#{date}-#{id}"
    self.update_columns(phone_call_id: call_id)
  end
end
