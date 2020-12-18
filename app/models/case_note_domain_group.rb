class CaseNoteDomainGroup < ApplicationRecord
  mount_uploaders :attachments, FileUploader
  belongs_to :case_note
  belongs_to :domain_group

  has_many :tasks

  has_paper_trail

  validates :domain_group, presence: true

  default_scope { order(:domain_group_id) }

  def completed_tasks
    tasks.with_deleted.completed
  end

  def on_going_tasks
    tasks.with_deleted.upcoming
  end

  def any_assessment_domains?(case_note)
    domains = if case_note.custom?
                case_note.custom_assessment_setting_id.nil? ? domain_group.domains.custom_csi_domains : domain_group.domains.custom_csi_domains.where(custom_assessment_setting_id: case_note.custom_assessment_setting_id)
              else
                domain_group.domains.csi_domains
              end

    domains.assessment_domains_by_assessment_id(case_note.assessment_id).any?
  end

  def domains(case_note)
    return [] unless domain_group
    if case_note.custom?
      case_note.custom_assessment_setting_id.present? ? domain_group.domains.custom_csi_domains.where(custom_assessment_setting_id: case_note.custom_assessment_setting_id) : domain_group.domains.custom_csi_domains
    else
      domain_group.domains.csi_domains
    end
  end

  def domain_identities(custom_assessment_setting_id=nil)
    case_note.custom? ? domain_group.custom_domain_identities(custom_assessment_setting_id) : domain_group.default_domain_identities
  end
end
