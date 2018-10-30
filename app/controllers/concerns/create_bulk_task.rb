module CreateBulkTask
  TASK_HEADER = ['name', 'completion_date', 'domain_id', 'relation', 'user_id']

  def create_bulk_task(task_in_params)
    task_attr = task_in_params.map {|task| [TASK_HEADER, task.split(', ') << current_user.id].transpose.to_h }
    tasks = @client.tasks.create(task_attr)
    tasks.each {|task| Calendar.populate_tasks(task) }
  end
end
