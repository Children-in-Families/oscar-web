namespace :assessment_data_to_care_plan do
  desc 'move goal & task from assessment to care plan'
  task :move, [:short_name] => :environment do |task, args|
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      Client.joins(:assessments).distinct.each do |client|
        client.assessments.completed.each do |assessment|
          care_plan = CarePlan.create(client_id: client.id, assessment_id: assessment.id, completed: true, created_at: assessment.created_at)
          assessment.assessment_domains.each do |ad|
            if ad.goal != ""
              goal_attr = Goal.new(assessment_domain_id: ad.id, assessment_id: assessment.id, description: ad.goal, client_id: client.id).attributes
              goal = care_plan.goals.create(goal_attr)
              puts "- created goal #{goal.id} for care plan#{care_plan.id} in #{org.short_name}"
              client.tasks.by_domain_id(ad.domain_id).incomplete.each do |task|
                next if task.goal_id.present?
                task.update_attributes(goal_id: goal.id)
                puts "- added goal_id #{goal.id} to task in #{org.short_name}"
              end
            end
          end
        end
        puts "created care plan and nested attribute for #{client.slug} from NGO #{org.short_name}"
      end
    end
  end
end
