class CaseNoteSerializer < ActiveModel::Serializer
  attributes :id, :attendee, :meeting_date, :interaction_type, :note, :client_id, :assessment_id, :case_note_domain_groups,
             :selected_domain_group_ids, :attachments, :draft, :custom, :tasks, :created_at, :updated_at

  private

  def case_note_domain_groups
    ActiveModel::ArraySerializer.new(object.case_note_domain_groups, each_serializer: CaseNoteDomainGroupSerializer)
  end

  def tasks
    tasks = Task.completed.where(case_note_id: object.id)
    [*object.tasks, *tasks]
  end
end
