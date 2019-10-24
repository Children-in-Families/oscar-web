class SystemNotification < ActiveRecord::Base
  TYPES = ['task', 'case note', 'assessment', 'custom form', 'tracking form']

  belongs_to :user

  validates :notification_type, presence: true, inclusion: { in: TYPES }
  scope :task_notifications, -> { where(notification_type: 'task') }
  scope :case_note_notifications, -> { where(notification_type: 'case note') }
  scope :assessment_notifications, -> { where(notification_type: 'assessment') }
  scope :custom_form_notifications, -> { where(notification_type: 'custom form') }
  scope :tracking_form_notifications, -> { where(notification_type: 'tracking form') }

end
