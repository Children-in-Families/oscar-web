module CreateBulkTask
  include GoogleCalendarServiceConcern

  def create_bulk_task(task_in_params, parent = nil)
    case_note = parent.class.to_s =~ /decorator/i ? parent.object : parent
    task_attr = task_in_params.map do |task|
      task_attr = JSON.parse(task)
      task_attr['name'] = task_attr['name'].gsub('qout', '"').gsub('apos', "'")
      task_attr['taskable_id'] = parent.id
      task_attr['taskable_type'] = case_note.class.to_s
      task_attr['expected_date'] = task_attr['expected_date']

      task_attr.merge('case_note_id' => parent.id.to_s, user_id: current_user.id, domain_group_identity: task_attr['domain_group_identity'].to_s)
    end

    tasks = case_note.parent.tasks.create(task_attr)
    tasks.each { |task| Calendar.populate_tasks(task) }
    create_events if session[:authorization]
  end

  def create_task_task_progress_notes
    (params.dig(:case_note)['case_note_domain_groups_attributes'].try(:values) || []).each do |case_note_domain_groups_attributes|
      case_note_domain_groups_attr = case_note_domain_groups_attributes
      case_note_domain_group_id = case_note_domain_groups_attr['id']
      tasks_attributes = case_note_domain_groups_attr['tasks_attributes']
      tasks_attributes = tasks_attributes.values || []
      tasks_attributes.each do |tasks_attr|
        task_id = tasks_attr['id']
        if task_id.present?
          task = Task.find(task_id)
          task_progress_notes_attributes = []
          next if tasks_attr['task_progress_notes_attributes'].nil?

          tasks_attr['task_progress_notes_attributes'].each do |k,v|
            next if v['task_id'].present?
            task_progress_notes_attributes << v.select{|h| h['progress_note'] }
          end
          task.task_progress_notes.create(task_progress_notes_attributes) if task_progress_notes_attributes.present?
        end
      end
    end
  end
end
