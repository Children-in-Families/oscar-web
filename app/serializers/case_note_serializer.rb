class CaseNoteSerializer < ActiveModel::Serializer
  attributes :id, :attendee, :meeting_date, :interaction_type, :note, :client_id, :assessment_id, :case_note_domain_groups, :selected_domain_group_ids, :attachments, :created_at, :updated_at

  def case_note_domain_groups
    ActiveModel::ArraySerializer.new(object.case_note_domain_groups, each_serializer: CaseNoteDomainGroupSerializer)
  end
end
