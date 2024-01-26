namespace :cache do
  desc 'clear rails cache'
  task clear: :environment do
    Rails.cache.clear
  end

  desc 'flush cache for field settings'
  task :flish_field_settings => :environment do
    Organization.completed.each do |org|
      Organization.switch_to org.short_name
      puts "flush cache for #{org.short_name}"
      FieldSetting.find_each(&:touch)
    end
  end
end
