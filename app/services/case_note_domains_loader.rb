class CaseNoteDomainsLoader < ServiceBase
  attr_reader :caset_note

  def initialize(caset_note)
    @caset_note = caset_note
  end

  def call
    return caset_note.case_note_domain_groups if caset_note.persisted? || caset_note.client_id.blank?

    domain_group_ids.map do |domain_group_id|
      CaseNoteDomainGroup.new(domain_group_id: domain_group_id)
    end
  end

  private

  def domain_group_ids
    @domain_group_ids ||= if caset_note.custom?
      custom_domain_setting = CustomAssessmentSetting.find_by(id: caset_note.custom_assessment_setting_id)
      custom_domain_setting.present? ? custom_domain_setting.domains.pluck(:domain_group_id).uniq : []
    else
      Domain.csi_domains.where(custom_assessment_setting_id: nil).pluck(:domain_group_id).uniq
    end
  end
end
