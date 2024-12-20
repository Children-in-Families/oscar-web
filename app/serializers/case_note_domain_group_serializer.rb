class CaseNoteDomainGroupSerializer < ActiveModel::Serializer
  attributes :note, :case_note_id, :domain_group_id, :id, :domain_scores, :attachments, :completed_tasks, :domain_group_identities

  has_many :tasks

  def domain_scores
    return [] unless object.case_note

    object.domains(object.case_note).map do |domain|
      ad = domain.assessment_domains.find_by(assessment_id: object.case_note.assessment_id)
      { domain_id: ad.domain_id, score: ad.score } if ad.present?
    end.compact
  end

  def domain_group_identities
    object.domain_identities
  end

  def attachments
    object.attachments? ? object.attachments : []
  end
end
