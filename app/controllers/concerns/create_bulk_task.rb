module CreateBulkTask
  include GoogleCalendarServiceConcern

  def create_bulk_task(task_in_params, parent = nil)
    case_note = parent.class.to_s =~ /decorator/i ? parent.object : parent
    task_attr = task_in_params.map do |task_param|
      task_attr = task_param.is_a?(String) ? JSON.parse(task_param) : task_param.to_a.to_h
      task_attr['name'] = task_attr['name'].gsub('qout', '"').gsub('apos', "'")
      task_attr['taskable_id'] = parent.id
      task_attr['taskable_type'] = case_note.class.to_s
      task_attr['expected_date'] = task_attr['expected_date']
      case_note_domain_group_id = case_note.case_note_domain_groups.find_by(domain_group_id: task_attr['domain_group_identity']).try(:id)
      task_attr.merge(
        'case_note_id' => parent.id.to_s,
        user_id: current_user.id,
        case_note_domain_group_id: case_note_domain_group_id,
        domain_group_identity: task_attr['domain_group_identity'].to_s
      )
    end

    tasks = case_note.parent.tasks.create(task_attr)
    tasks.each { |task| Calendar.populate_tasks(task) }
    create_events if session[:authorization]
  end
end
