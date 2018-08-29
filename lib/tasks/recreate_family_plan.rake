namespace :family_plan_and_status do
  desc "Recreate family plan"
  task reorder: :environment do
    Rake::Task['db:seed'].invoke
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      family_plan = FamilyPlan.find_by(name: 'ផ្សេងៗ')
      family_plan.update(created_at: Time.zone.now) if family_plan.present?
    end
  end
  puts 'done!'
end
