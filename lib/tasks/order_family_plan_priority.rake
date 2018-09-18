namespace :family_plan_priority do
  desc 'Order Family Plan Priority'
  task order: :environment do |task, args|
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      family_plans = [
        {name: 'ការការពារ និងការថែទាំ', priority: 1},
        {name: 'ភាពស្និតស្នាលរវាងកុមារនិងអ្នកថែទាំ', priority: 2},
        {name: 'សុខភាពផ្លូវកាយ', priority: 3},
        {name: 'សុខភាពផ្លូវចិត្ត', priority: 4},
        {name: 'ឆន្ទៈក្នុងការធ្វើឲ្យស្ថានភាពបានប្រសើរឡើង', priority: 5},
        {name: 'មុខរបរ និងជំនាញនានាដែលអាចរកចំណូលបាន', priority: 6},
        {name: 'ទំនាក់ទំនងសង្គម', priority: 7},
        {name: 'កម្រិតសិក្សាអប់រំ', priority: 8},
        {name: 'ចំណេះដឹងទូទៅក្នុងសង្គម', priority: 9},
        {name: 'ធនធាននានា(ដីធ្លី ផ្ទះ...)', priority: 10},
        {name: 'ជំនួយពីសាច់ញាតិ', priority: 11},
        {name: 'ការគាំទ្រពីសហគមន៍', priority: 12},
        {name: 'កូនៗផ្សេងទៀតដែលអាចជួយបាន', priority: 13},
        {name: 'កូនៗផ្សេងទៀតដែលអាចជួយគ្រួសារបាន', priority: 14},
        {name: 'ផ្សេងៗ', priority: 15}
      ]

      family_plans.each do |plan|
        family_plan = FamilyPlan.find_by(name: plan[:name])
        family_plan.update(priority: plan[:priority]) if family_plan.present?
      end
    end
  end
end
