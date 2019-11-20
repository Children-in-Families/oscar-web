namespace :change_assessment_data do
  desc 'Faking Assessment data in development and staging'
  task :update, [:short_name] => :environment do |task, args|
    if Rails.env.development? || Rails.env.staging? || Rails.env.demo?
      dummy_text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
      Organization.switch_to args.short_name

      sql = "UPDATE assessment_domains SET note = '#{dummy_text}', reason = '#{dummy_text}', goal = '#{dummy_text}', attachments = ARRAY[]::varchar[]"
      ActiveRecord::Base.connection.execute(sql)

      puts "Done updating assessment!!!"
    end
  end
end
