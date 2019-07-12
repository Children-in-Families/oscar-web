namespace :incompleted_assessment do
  desc "Delete incompleted assessment after one week of creation"
  task delete: :environment do
    Organization.all.each do |org|
      next if org.short_name == 'shared'
      Organization.switch_to org.short_name
      incompleted_assessment = []
      Assessment.incompleted.each do |assessment|
        incompleted_assessment << assessment.id if (assessment.created_at.to_date + 6.days) > Date.today
      end
      Assessment.where(id: incompleted_assessment).delete_all if incompleted_assessment.present?
      
    end
    puts 'Incompleted assesssment deleted!!!'
  end
end
