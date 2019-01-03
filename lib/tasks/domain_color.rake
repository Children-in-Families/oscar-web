namespace :domain_color do
  desc "Update domain color"
  task update: :environment do |task, args|
    Organization.all.each do |org|
      next if org.short_name == 'shared'
      Organization.switch_to org.short_name
      Domain.all.each do |domain|
        domain.score_1_color = 'success' if domain.score_1_color == 'info'
        domain.score_2_color = 'success' if domain.score_2_color == 'info'
        domain.score_3_color = 'success' if domain.score_3_color == 'info'
        domain.score_4_color = 'success' if domain.score_4_color == 'info'
        domain.save
      end
    end
    puts 'Done updating!!!'
  end
end
