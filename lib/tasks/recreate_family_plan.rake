namespace :family_plan_and_status do
  desc "Recreate family plan"
  task reorder: :environment do
    Rake::Task['db:seed'].invoke
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      family_plan_without_family_word = FamilyPlan.find_by(name: 'កូនៗផ្សេងទៀតដែលអាចជួយបាន')
      family_plan_with_family_word    = FamilyPlan.find_by(name: 'កូនៗផ្សេងទៀតដែលអាចជួយគ្រួសារបាន')
      next if family_plan_without_family_word.nil?
      government_forms = GovernmentForm.includes(:government_form_family_plans).where(name: "ទម្រង់ទី៣: ផែនការសេវាសំរាប់ករណី​ និង គ្រួសារ" )
      government_forms.each do |government_form|
        government_form.government_form_family_plans.where(family_plan_id: family_plan_without_family_word.id).update_all(family_plan_id: family_plan_with_family_word.id)
      end
    end
  end
  puts 'done!'
end
