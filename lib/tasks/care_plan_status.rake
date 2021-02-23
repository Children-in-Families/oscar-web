namespace :care_plan_status do
  desc 'update care plan to completed'
  task :update, [:short_name] => :environment do |task, args|
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      CarePlan.update_all(completed: true)
      puts 'changed care plan status completed'
      Assessment.joins(:care_plan).distinct.each do |assessment|
        assessment.care_plan.update_attributes(created_at: assessment.created_at)
      end
      puts "changed care plan created date completed"
    end
  end
end
