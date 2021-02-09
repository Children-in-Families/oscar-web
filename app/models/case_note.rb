class CaseNote < ActiveRecord::Base
  INTERACTION_TYPE = ['Visit', 'Non face to face', '3rd Party', 'Supervision', 'Other'].freeze
  paginates_per 1

  belongs_to :client
  belongs_to :family
  belongs_to :assessment
  belongs_to :custom_assessment_setting, required: false
  has_many   :case_note_domain_groups, dependent: :destroy
  has_many   :domain_groups, through: :case_note_domain_groups
  has_many   :tasks, as: :taskable

  validates :meeting_date, :attendee, presence: true
  validates :interaction_type, presence: true, inclusion: { in: INTERACTION_TYPE }
  validate  :existence_domain_groups

  has_paper_trail

  accepts_nested_attributes_for :case_note_domain_groups

  scope :most_recents, -> { order(created_at: :desc) }
  scope :recent_meeting_dates , -> { order(meeting_date: :desc) }

  scope :no_case_note_in, ->(value) { where('meeting_date <= ? AND id = (SELECT MAX(cn.id) FROM CASE_NOTES cn where CASE_NOTES.client_id = cn.client_id)', value) }

  before_create :set_assessment

  def populate_notes(custom_id, custom_case_note)
    if custom_case_note == "true"
      custom_domain_setting = CustomAssessmentSetting.find(custom_id)
      return [] if custom_domain_setting.nil?
      domain_group_ids = custom_domain_setting.domains.pluck(:domain_group_id).uniq
      domain_group_ids.each do |domain_group_id|
        case_note_domain_groups.build(domain_group_id: domain_group_id)
      end
    else
      domain_group_ids = Domain.csi_domains.where(custom_assessment_setting_id: nil).pluck(:domain_group_id).uniq
      domain_group_ids.each do |domain_group_id|
        case_note_domain_groups.build(domain_group_id: domain_group_id)
      end
    end
  end

  def complete_tasks(params)
    return if params.nil?
    params.each do |_, param|
      next unless param[:domain_group_id]
      case_note_domain_group = case_note_domain_groups.find_by(domain_group_id: param[:domain_group_id])
      task_ids = param[:task_ids] || []
      case_note_tasks = Task.with_deleted.where(id: task_ids)
      next if case_note_tasks.reject(&:blank?).blank?

      task_attributes = case_note_tasks.map do |task|
        task.attributes.slice('name', 'expected_date', 'remind_at', 'completed', 'user_id', 'case_note_domain_group_id', 'domain_id', 'client_id', 'relation', 'family_id', 'goal_id', 'completion_date')
      end
      new_tasks = tasks.create(task_attributes)
      case_note_domain_group.tasks = new_tasks
      case_note_domain_group.tasks.with_deleted.set_complete(self)
      case_note_domain_group.save
    end
  end

  def self.latest_record
    where.not(meeting_date: nil).order(meeting_date: :desc).first
  end

  def parent
    family_id? ? family : client
  end

  private

  def set_assessment
    self.assessment = if custom?
                        parent.assessments.custom_latest_record
                      else
                        client.assessments.default_latest_record
                      end
  end

  def existence_domain_groups
    errors.add(:domain_groups, "#{I18n.t('domain_groups.form.domain_group')} #{I18n.t('cannot_be_blank')}") if domain_groups.present? && selected_domain_group_ids.blank?
  end

  def enable_default_assessment?
    setting = Setting.first
    setting && setting.enable_default_assessment
  end

  def not_using_assessment_tool?
    (!enable_default_assessment? && !CustomAssessmentSetting.all.all?(&:enable_custom_assessment))
  end
end
