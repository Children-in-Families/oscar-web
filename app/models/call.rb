class Call < ActiveRecord::Base
  CALL_TYPE = [
    'New Referral: Case Action Required',
    'New Referral: Notifier Concern',
    'Providing Update', 'Phone Counseling',
    'Seeking Information', 'Spam Call', 'Wrong Number']

  belongs_to :caller

  validates :receiving_staff_id, :start_datetime, :end_datetime, presence: true
  validates :call_type, presence: true, inclusion: { in: CALL_TYPE }
end
