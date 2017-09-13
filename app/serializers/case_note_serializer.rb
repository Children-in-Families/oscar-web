class CaseNoteSerializer < ActiveModel::Serializer
  attributes :attendee, :meeting_date, :interaction_type, :assessment_id, :id, :case_note_domain_groups, :created_at, :updated_at

  def case_note_domain_groups
    ActiveModel::ArraySerializer.new(object.case_note_domain_groups, each_serializer: CaseNoteDomainGroupSerializer)
  end
end
