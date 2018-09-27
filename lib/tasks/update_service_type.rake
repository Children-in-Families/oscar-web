namespace :service_type do
  desc 'update service type to match with pdf'
  task update: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name
      ServiceType.find_by(name: 'ការគាំទ្រផ្លូវចិត្ត').update_attributes(name: 'ការគាំទ្រផ្នែកផ្លូវចិត្ត')
      ServiceType.find_by(name: 'ការថែទាំវេជ្ជសាស្ត្រ').update_attributes(name: 'ការថែទាំផ្នែកវេជ្ជសាស្ត្រ')
    end
    puts 'Done!!!'
  end
end
