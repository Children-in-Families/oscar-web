namespace :update_field_settings do
  desc "Add require option to client legal documents fields"
  task add_require_options: :environment do
    Organization.all.each do |org|
      Organization.switch_to org.short_name

      field_name = %w(
        
      )
    end
  end
end
