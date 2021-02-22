namespace :care_plan_status do
  desc 'update care plan to completed'
  task :update, [:short_name] => :environment do |task, args|
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      CarePlan.update_all(completed: true)
    end
  end
end
