module CreateBulkTask
  def create_bulk_task(task_in_params, parent=nil)
    case_note = parent.class.to_s =~ /decorator/i ? parent.object : parent
    task_attr = task_in_params.map do |task|
      task_attr = JSON.parse(task)
      task_attr['name'] = task_attr['name'].gsub('qout', '"').gsub('apos', "'")
      task_attr['taskable_id'] = parent.id
      task_attr['taskable_type'] = case_note.class.to_s
      task_attr.merge('case_note_id'=> "#{parent.id}", user_id: current_user.id)
    end

    tasks =  case_note.parent.tasks.create(task_attr)
    tasks.each {|task| Calendar.populate_tasks(task) }
  end
end
