namespace :duplicated_tasks do
  desc 'Removed duplicated tasks for Ratanak'
  task remove: :environment do
    Apartment::Tenant.switch 'ratanak'
    sql = 'SELECT t1.id, t1.name, t1.expected_date, t1.case_note_domain_group_id FROM tasks t1 JOIN (SELECT name, expected_date, case_note_domain_group_id FROM tasks GROUP BY name, expected_date, case_note_domain_group_id HAVING COUNT(*) > 1) t2 ON t1.name = t2.name AND t1.expected_date = t2.expected_date AND t1.case_note_domain_group_id = t2.case_note_domain_group_id'
    tasks = Task.find_by_sql(sql)

    deleted_ids = []
    tasks.group_by do |task|
      [task.name, task.expected_date, task.case_note_domain_group_id]
    end.each do |_, grouped_tasks|
      next if grouped_tasks.size <= 1

      deleted_ids << grouped_tasks.last.id
    end
    ActiveRecord::Base.connection.execute("DELETE FROM ratanak.tasks where id IN (#{deleted_ids.join(', ')})")
  end
end
