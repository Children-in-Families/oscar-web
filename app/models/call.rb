class Call < ActiveRecord::Base

  # enum call_type: {
  #             case_action_required: I18n.t('calls.type.case_action_required'),
  #             notifier_concern: I18n.t('calls.type.notifier_concern'),
  #             providing_update: I18n.t('calls.type.providing_update'),
  #             phone_counseling: I18n.t('calls.type.phone_counseling'),
  #             seeking_information: I18n.t('calls.type.seeking_information'),
  #             spam_call: I18n.t('calls.type.spam_call'),
  #             wrong_number: I18n.t('calls.type.wrong_number')
  #           }
  FIELDS = %w( phone_call_id call_type start_datetime end_datetime phone_counselling_summary information_provided )
  TYPES  = [
            "New Referral: Case Action Required", "New Referral: Case Action NOT Required",
            "Providing Update", "Phone Counselling",
            "Seeking Information", "Spam Call", "Wrong Number"
          ]

  belongs_to :referee
  belongs_to :receiving_staff, class_name: 'User',      foreign_key: 'receiving_staff_id'

  has_many :hotlines, dependent: :destroy
  has_many :clients, through: :hotlines

  scope :most_recents, -> { order(date_of_call: :desc) }

  after_save :set_phone_call_id, if: -> { phone_call_id.blank? }

  validates :receiving_staff_id, :date_of_call, :start_datetime, :end_datetime, presence: true
  # validates :call_type, presence: true, inclusion: { in: call_types.values }

  # validates :phone_counselling_summary, presence: true, if: :phone_counseling?
  # validates :information_provided, presence: true, if: :seeking_information?

  # def phone_counseling?
  #   call_type == "Phone Counselling"
  # end

  # def seeking_information?
  #   call_type == "Seeking Information"
  # end

  def case_action_not_required?
    call_type == "New Referral: Case Action NOT Required"
  end

  def set_phone_call_id
    id      = self.id.to_s.rjust(4, '0')
    date    = self.date_of_call.strftime('%Y%m%d')
    call_id = "#{date}-#{id}"
    self.update_columns(phone_call_id: call_id)
  end
end
