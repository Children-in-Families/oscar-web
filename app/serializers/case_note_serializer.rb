class CaseNoteSerializer < ActiveModel::Serializer
  attributes :attendee, :meeting_date, :interaction_type, :assessment_id, :id, :case_note_domain_groups, :case_note_domain_group, :selected_domain_group_ids, :created_at, :updated_at

  def case_note_domain_groups
    ActiveModel::Serializer::CollectionSerializer.new(object.case_note_domain_groups, each_serializer: CaseNoteDomainGroupSerializer)
  end

  def case_note_domain_group
    ActiveModel::Serializer::CollectionSerializer.new(object.case_note_domain_groups, each_serializer: CaseNoteDomainGroupSerializer)
  end
end
