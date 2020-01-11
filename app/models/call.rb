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

  belongs_to :referee

  # validates :receiving_staff_id, :start_datetime, :end_datetime, presence: true
  # validates :call_type, presence: true, inclusion: { in: call_types.values }

  # validates :phone_counselling_summary, presence: true, if: :phone_counseling?
  # validates :information_provided, presence: true, if: :seeking_information?

  # def phone_counseling?
  #   call_type == "Phone Counseling"
  # end

  # def seeking_information?
  #   call_type == "Seeking Information"
  # end
end
