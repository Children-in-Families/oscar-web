class CaseNoteDomainGroup < ActiveRecord::Base
  mount_uploaders :attachments, FileUploader
  belongs_to :case_note
  belongs_to :domain_group

  has_many :tasks

  has_paper_trail

  validates :domain_group, presence: true

  default_scope { order(:domain_group_id) }

  def completed_tasks
    tasks.completed
  end

  def any_assessment_domains?(case_note)
    domains = case_note.custom? ? domain_group.domains.custom_csi_domains : domain_group.domains.csi_domains
    domains.assessment_domains_by_assessment_id(case_note.assessment_id).any?
  end

  def domains(case_note)
    case_note.custom? ? domain_group.domains.custom_csi_domains : domain_group.domains.csi_domains
  end

  def domain_identities
    case_note.custom? ? domain_group.custom_domain_identities : domain_group.default_domain_identities
  end
end
