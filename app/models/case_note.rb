class CaseNote < ActiveRecord::Base
  include ClearanceOverdueConcern

  INTERACTION_TYPE = ['Visit', 'Come to us', 'Non face to face', '3rd Party', 'Supervision', 'Other'].freeze
  paginates_per 1

  mount_uploaders :attachments, FileUploader

  belongs_to :client
  belongs_to :family
  belongs_to :assessment
  belongs_to :custom_assessment_setting, required: false
  has_many :case_note_domain_groups, dependent: :destroy
  has_many :domain_groups, through: :case_note_domain_groups
  has_many :tasks, as: :taskable

  has_one :custom_field_property, class_name: 'CaseNotes::CustomFieldProperty', dependent: :destroy

  validates :meeting_date, :attendee, presence: true
  validates :interaction_type, presence: true, inclusion: { in: INTERACTION_TYPE }
  validate :existence_domain_groups

  has_paper_trail

  accepts_nested_attributes_for :custom_field_property
  accepts_nested_attributes_for :case_note_domain_groups
  accepts_nested_attributes_for :tasks, reject_if: proc { |attributes| attributes['name'].blank? && attributes['expected_date'].blank? }, allow_destroy: true

  before_save :populate_associations

  scope :most_recents, -> { order(created_at: :desc) }
  scope :recent_meeting_dates, -> { order(draft: :desc, meeting_date: :desc, last_auto_save_at: :desc) }
  scope :draft, -> { where(draft: true) }
  scope :draft_untouch, -> { draft.where(last_auto_save_at: nil) }
  scope :not_untouch_draft, -> { where('draft IS FALSE OR last_auto_save_at IS NOT NULL') }

  scope :no_case_note_in, -> (value) { where('meeting_date <= ? AND id = (SELECT MAX(cn.id) FROM CASE_NOTES cn where CASE_NOTES.client_id = cn.client_id)', value) }

  scope :default, -> { where(custom_assessment_setting_id: nil) }
  scope :custom, -> { where.not(custom_assessment_setting_id: nil) }

  default_scope { not_untouch_draft }

  before_create :set_assessment

  def populate_notes(custom_id, custom_case_note)
    # family_domains = Domain.family_custom_csi_domains
    # family_domains.where.not(id: domains.ids).each do |domain|
    #   assessment_domains.build(domain: domain)
    # end
    if custom_case_note == 'true'
      custom_domain_setting = CustomAssessmentSetting.find(custom_id)
      return [] if custom_domain_setting.nil?
      domain_group_ids = custom_domain_setting.domains.pluck(:domain_group_id).uniq
      domain_group_ids.each do |domain_group_id|
        case_note_domain_groups.build(domain_group_id: domain_group_id)
      end
    else
      domain_group_ids = Domain.csi_domains.where(custom_assessment_setting_id: nil).pluck(:domain_group_id).uniq
      DomainGroup.where.not(id: domain_groups.ids).where(id: domain_group_ids).ids.each do |domain_group_id|
        case_note_domain_groups.build(case_note_id: id, domain_group_id: domain_group_id)
      end
    end
  end

  def complete_tasks(case_note_domain_groups_params, current_user_id = nil)
    return if case_note_domain_groups_params.nil?

    case_note_domain_groups_params.to_a.each do |array_attr, param|
      if param
        handle_complete_task_from_web(param, current_user_id)
      else
        handle_complete_task_from_api(array_attr, current_user_id)
      end
    end
  end

  def complete_screening_tasks(param)
    attr = param[:case_note][:tasks_attributes].to_a.map { |_, attr| [attr[:id], (attr['completion_date'] = meeting_date; attr)] }.to_h
    Task.update(attr.keys, attr.values)
    Task.where(id: attr.keys).update_all(case_note_id: id) unless tasks.where(id: attr.keys).any?
  end

  def any_tasks_screening_assessments?(screening_assessments)
    tasks.where(taskable_type: 'ScreeningAssessment', taskable_id: screening_assessments.ids).any?
  end

  def self.latest_record
    where.not(meeting_date: nil).order(meeting_date: :desc).first
  end

  def parent
    family_id? ? family : client
  end

  def service_delivery_task(param, case_note_tasks)
    if Organization.ratanak?
      param['tasks_attributes'] && param['tasks_attributes'].to_a.each do |_, task_param|
        next if task_param.blank?

        service_delivery_task_ids = task_param['service_delivery_task_ids'].reject(&:blank?) if task_param['service_delivery_task_ids']
        task = case_note_tasks.find_by(id: task_param['id'])
        if task.present?
          task.create_service_delivery_tasks(service_delivery_task_ids) if service_delivery_task_ids.present?

          task.reload
          task.update_attributes(completion_date: task_param['completion_date']) if task_param['completion_date'].present?
        end
      end
    end
  end

  def is_editable?
    return true if draft?

    setting = Setting.first
    return true if setting.try(:case_note_edit_limit).zero?
    case_note_edit_limit = setting.try(:case_note_edit_limit).zero? ? 2 : setting.try(:case_note_edit_limit)
    edit_frequency = setting.try(:case_note_edit_frequency)
    created_at >= case_note_edit_limit.send(edit_frequency).ago
  end

  private

  def populate_associations
    self.case_note_domain_groups = ::CaseNoteDomainsLoader.call(self)
  end

  def set_assessment
    self.assessment = if custom?
                        parent.assessments.custom_latest_record
                      else
                        parent.assessments.default_latest_record
                      end
  end

  def existence_domain_groups
    errors.add(:domain_groups, "#{I18n.t('domain_groups.form.domain_group')} #{I18n.t('cannot_be_blank')}") if domain_groups.any? && selected_domain_group_ids.blank?
  end

  def enable_default_assessment?
    setting = Setting.first
    setting && setting.enable_default_assessment
  end

  def not_using_assessment_tool?
    (!enable_default_assessment? && !CustomAssessmentSetting.all.all?(&:enable_custom_assessment))
  end

  def handle_complete_task_from_web(param, current_user_id)
    return unless param[:domain_group_id]

    task_ids = param['tasks_attributes'] && param['tasks_attributes'].values.reject { |h| h['completed'] == '0' }.map { |h| h['id'] } || []
    return if task_ids.blank?

    case_note_domain_group = case_note_domain_groups.find_by(domain_group_id: param[:domain_group_id])
    case_note_tasks = Task.with_deleted.where(id: task_ids)
    return if case_note_tasks.reject(&:blank?).blank?

    case_note_tasks.update_all(case_note_domain_group_id: case_note_domain_group.id)
    case_note_domain_group.reload
    case_note_domain_group.tasks.with_deleted.set_complete(self, current_user_id)
    service_delivery_task(param, case_note_tasks)
    case_note_domain_group.save
  end

  def handle_complete_task_from_api(array_attr, current_user_id)
    task_ids = array_attr['tasks_attributes'] && array_attr['tasks_attributes'].reject { |h| h['completed'] == '0' }.map { |h| h['id'] } || []
    return if task_ids.blank?

    case_note_domain_group = case_note_domain_groups.find_by(domain_group_id: array_attr[:domain_group_id])
    case_note_tasks = Task.with_deleted.where(id: task_ids)
    return if case_note_tasks.reject(&:blank?).blank?

    case_note_tasks.update_all(case_note_domain_group_id: case_note_domain_group.id)
    case_note_domain_group.reload
    case_note_domain_group.tasks.with_deleted.set_complete(self, current_user_id)
    # service_delivery_task(array_attr, case_note_tasks)
    case_note_domain_group.save
  end
end
