module CreateBulkTask
  def create_bulk_task(task_in_params, parent_id=nil)
    task_attr = task_in_params.map do |task|
      task_attr = JSON.parse(task)
      task_attr['name'] = task_attr['name'].gsub('qout', '"').gsub('apos', "'")
      task_attr.merge('case_note_id'=> "#{parent_id}", user_id: current_user.id)
    end

    tasks = @client.tasks.create(task_attr)
    tasks.each {|task| Calendar.populate_tasks(task) }
  end
end
