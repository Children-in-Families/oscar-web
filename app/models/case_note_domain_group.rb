class CaseNoteDomainGroup < ActiveRecord::Base
  mount_uploaders :attachments, FileUploader
  belongs_to :case_note
  belongs_to :domain_group

  has_many :tasks

  has_paper_trail

  validates :domain_group, presence: true

  accepts_nested_attributes_for :tasks, reject_if: proc { |attribute| attribute['name'].blank? && attribute['case_note_domain_group_id'].blank? }, allow_destroy: true

  delegate :family, to: :case_note, allow_nil: true
  delegate :id, to: :family, prefix: true, allow_nil: true

  default_scope { order(:domain_group_id) }

  def completed_tasks
    tasks.completed
  end

  def on_going_tasks
    tasks.with_deleted.upcoming
  end

  def any_assessment_domains?(case_note)
    domains = if case_note.custom? && case_note.custom_assessment_setting_id.present?
                domain_group.domains.custom_csi_domains.where(custom_assessment_setting_id: case_note.custom_assessment_setting_id)
              elsif case_note.custom?
                if case_note.family_id?
                  domain_group.domains.family_custom_csi_domains
                else
                  domain_group.domains.custom_csi_domains
                end
              else
                domain_group.domains.csi_domains
              end

    domains.assessment_domains_by_assessment_id(case_note.assessment_id).any?
  end

  def domains(case_note)
    return [] unless domain_group

    if case_note && case_note.custom?
      return domain_group.domains.custom_csi_domains.where(custom_assessment_setting_id: case_note.custom_assessment_setting_id) if case_note.custom_assessment_setting_id.present?

      if case_note.family_id?
        domain_group.domains.family_custom_csi_domains
      else
        domain_group.domains.custom_csi_domains
      end
    else
      domain_group.domains.csi_domains
    end
  end

  def domain_identities(custom_assessment_setting_id = nil)
    return domain_group.custom_domain_identities(custom_assessment_setting_id) if case_note.custom? && case_note.client_id?

    if case_note.family_id?
      domain_group.family_domain_name
    else
      domain_group.default_domain_identities
    end
  end
end
