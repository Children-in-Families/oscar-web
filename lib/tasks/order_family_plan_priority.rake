namespace :family_plan_priority do
  desc 'Order Family Plan Priority'
  task order: :environment do |task, args|
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      family_plans = ['ការការពារ និងការថែទាំ', 'ភាពស្និទ្ធស្នាលរវាងកុមារនិងអ្នកថែទាំ', 'សុខភាពផ្លូវកាយ', 'សុខភាពផ្លូវចិត្ត', 'ឆន្ទៈក្នុងការធ្វើឲ្យស្ថានភាពបានប្រសើរឡើង', 'ឆន្ទៈនិងលទ្ធភាពក្នុងការបន្តធ្វើឲ្យស្ថានភាពបានប្រសើរឡើង', 'មុខរបរ និងជំនាញនានាដែលអាចរកចំណូលបាន', 'ទំនាក់ទំនងសង្គម', 'ទំនាក់ទំនងក្នុងសង្គម',
                      'កម្រិតសិក្សាអប់រំ', 'ចំណេះដឹងទូទៅក្នុងសង្គម', 'ធនធាននានា(ដីធ្លី ផ្ទះ...)', 'ជំនួយពីសាច់ញាតិ', 'ជំនួយពីសាច់ញាតិ (ទោះបីមានពិន្ទុតិចជាង២ក៏អាចបិទបានដែរ)', 'ការគាំទ្រពីសហគមន៍', 'កូនៗផ្សេងទៀតដែលអាចជួយបាន', 'កូនៗផ្សេងទៀតដែលអាចជួយគ្រួសារបាន', 'ផ្សេងៗ']

      FamilyPlan.find_by(name: 'ភាពស្និតស្នាលរវាងកុមារនិងអ្នកថែទាំ').update(name: 'ភាពស្និទ្ធស្នាលរវាងកុមារនិងអ្នកថែទាំ') if FamilyPlan.find_by(name: 'ភាពស្និតស្នាលរវាងកុមារនិងអ្នកថែទាំ').present?

      family_plans.each_with_index do |plan, index|
        family_plan = FamilyPlan.find_by(name: plan)
        family_plan.update(priority: index + 1) if family_plan.present?
      end
    end
  end
end
