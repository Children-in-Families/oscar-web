class CaseNote < ActiveRecord::Base
  INTERACTION_TYPE = ['Visit', 'Non face to face', '3rd Party','Supervision','Other'].freeze
  paginates_per 1

  belongs_to :client
  belongs_to :assessment
  has_many   :case_note_domain_groups, dependent: :destroy
  has_many   :domain_groups, through: :case_note_domain_groups

  validates :meeting_date, :attendee, presence: true
  validates :interaction_type, presence: true, inclusion: { in: INTERACTION_TYPE }
  validates :note, presence: true, if: :not_using_assessment_tool?

  has_paper_trail

  accepts_nested_attributes_for :case_note_domain_groups

  scope :most_recents, -> { order(created_at: :desc) }
  scope :recent_meeting_dates , -> { order(meeting_date: :desc) }

  scope :no_case_note_in, ->(value) { where('meeting_date <= ? AND id = (SELECT MAX(cn.id) FROM CASE_NOTES cn where CASE_NOTES.client_id = cn.client_id)', value) }

  before_create :set_assessment

  def populate_notes(custom_name, default)
    if default == "false" || not_using_assessment_tool?
      DomainGroup.all.each do |dg|
        case_note_domain_groups.build(domain_group_id: dg.id)
      end
    else
      custom_domains = CustomAssessmentSetting.find_by(custom_assessment_name: custom_name)
      return [] if custom_domains.nil?
      custom_domains = custom_domains.domains.pluck(:domain_group_id).uniq
      custom_domains.each do |dg|
        case_note_domain_groups.build(domain_group_id: dg)
      end
    end
  end

  def complete_tasks(params)
    return if params.nil?
    params.each do |_index, param|
      case_note_domain_group = case_note_domain_groups.find_by(domain_group_id: param[:domain_group_id])
      task_ids = param[:task_ids] || []
      case_note_domain_group.tasks = Task.where(id: task_ids)
      case_note_domain_group.tasks.set_complete
      case_note_domain_group.save
    end
  end

  def self.latest_record
    where.not(meeting_date: nil).order(meeting_date: :desc).first
  end

  private

  def set_assessment
    self.assessment = custom? ? client.assessments.custom_latest_record : client.assessments.default_latest_record
  end

  def enable_default_assessment?
    setting = Setting.first
    setting && setting.enable_default_assessment
  end

  def not_using_assessment_tool?
    (!enable_default_assessment? && !CustomAssessmentSetting.all.all?(&:enable_custom_assessment))
  end
end
