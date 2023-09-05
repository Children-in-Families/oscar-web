desc 'Migrate integration date to its own column - one time rake task'
task migrate_integration_date: :environment do
  Organization.without_shared.each do |organization|
    Organization.switch_to organization.short_name
  
    if organization.integrated_date.present? && organization.last_integrated_date.blank?
      puts "Update last integrated date for #{current} - last integrated date: #{organization.integrated_date}"
      organization.update!(last_integrated_date: organization.integrated_date)
    end
  end
end
