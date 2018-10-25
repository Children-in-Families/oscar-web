namespace :change_assessment_data do
  desc 'Faking Assessment data in development and staging'
  task update: :environment do |task, args|
    if Rails.env.development? || Rails.env.staging?
      Organization.all.each do |org|
        next if org.short_name == 'shared'
        dummy_text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
        Organization.switch_to org.short_name
        Assessment.all.each do |assessment|
          assessment.assessment_domains.each do |domain|
            domain.score  = 4
            domain.note   = dummy_text
            domain.reason = dummy_text
            domain.goal   = dummy_text
            domain.attachments = []
            domain.save(validate: false)
          end
        end
      end

      puts "Done updating assessment!!!"
    end
  end
end
