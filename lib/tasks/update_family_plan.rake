namespace :family_plan do
  desc "Update family plan duplication and update name"
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      # family_plan = FamilyPlan.find_by(name: 'កូនៗផ្សេងទៀតដែលអាចជួយគ្រួសារបាន')
      # if family_plan.present?
      #   family_plan.name = 'កូនៗផ្សេងទៀតដែលអាចជួយបាន'
      #   family_plan.save
      # end
      # family_plan = FamilyPlan.last
      # next if family_plan.nil?
      # family_plan.government_form_family_plans.destroy_all
      # family_plan.destroy if family_plan.name == 'មុខរបរនិងជំនាញនានាដែលអាចរកចំណូលបាន'
      family_plan = FamilyPlan.find_by(name: 'មុខរបរនិងជំនាញនានាដែលអាចរកចំណូលបាន')
      next if family_plan.nil?
      family_plan.government_form_family_plans.destroy_all
      family_plan.destroy
    end
  end
  puts 'done!'
end
