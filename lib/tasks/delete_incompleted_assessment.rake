namespace :incompleted_assessment do
  desc "Delete incompleted assessment after one week of creation"
  task delete: :environment do
    Organization.all.each do |org|
      next if org.short_name == 'shared'
      Organization.switch_to org.short_name
      incompleted_assessment = []
      Assessment.incompleted.each do |assessment|
        incompleted_assessment << assessment.id if (Date.today - assessment.created_at.to_date).to_i > 7
      end
      Assessment.where(id: incompleted_assessment).delete_all if incompleted_assessment.present?

    end
    puts 'Incompleted assesssment deleted!!!'
  end
end
