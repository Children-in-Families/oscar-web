namespace :duplicated_tasks do
  desc 'Removed duplicated tasks for Ratanak'
  task remove: :environment do
    Apartment::Tenant.switch 'ratanak'
    sql = <<~SQL
      SELECT *
      FROM tasks AS t1
      WHERE EXISTS (
        SELECT 1
        FROM tasks AS t2
        WHERE t1.name = t2.name
          AND t1.expected_date = t2.expected_date
          AND t1.case_note_domain_group_id = t2.case_note_domain_group_id
          AND t1.domain_id = t2.domain_id
          AND t1.id <> t2.id
      )
      GROUP BY t1.id;
    SQL

    tasks = Task.find_by_sql(sql)

    deleted_ids = []
    tasks.group_by do |task|
      [task.name, task.expected_date, task.case_note_domain_group_id, task.domain_id]
    end.each do |_, grouped_tasks|
      next if grouped_tasks.size <= 1

      deleted_ids << grouped_tasks.last.id
    end

    if deleted_ids.any?
      ActiveRecord::Base.connection.execute("DELETE FROM ratanak.task_progress_notes where task_id IN (#{deleted_ids.join(', ')})")
      ActiveRecord::Base.connection.execute("DELETE FROM ratanak.service_delivery_tasks where task_id IN (#{deleted_ids.join(', ')})")
      ActiveRecord::Base.connection.execute("DELETE FROM ratanak.tasks where id IN (#{deleted_ids.join(', ')})")
    end
  end
end
