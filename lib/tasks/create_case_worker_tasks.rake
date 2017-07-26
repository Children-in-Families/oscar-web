namespace :case_worker_task do
  desc 'Create case worker tasks'
  task create: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      Task.all.each do |task|
        task.case_worker_tasks.find_or_create_by(user_id: task.user_id) if task.user_id.present?
      end
    end
  end
end
