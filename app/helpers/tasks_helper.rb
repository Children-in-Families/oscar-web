module TasksHelper
  def domains_tasks(case_note, case_note_domain_group)
    case_note.client.tasks.where(domain_id: case_note_domain_group.domain_group.domains.ids)
  end
end
