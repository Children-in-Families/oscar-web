namespace :wtmy_data do
    desc 'Import data for use in the local Development environment only!'
    task import: :environment do
      exit unless Rails.env.development?
      tenant_name = 'wtmy'
      general_data_file = 'lib/devdata/general.xlsx'
      service_data_file = 'lib/devdata/services/service.xlsx'
      begin
        # Organization.create_and_build_tenant(full_name: 'Shared', short_name: 'shared')
      rescue Apartment::TenantExists => e
        puts "Shared tenant exists already."
      end
      begin
        # Organization.create_and_build_tenant(short_name: tenant_name, full_name: 'Anjali House', logo: File.open(Rails.root.join('app/assets/images/anjali logo.png')))
        Organization.switch_to tenant_name
        Rake::Task['db:seed'].invoke
        ImportStaticService::DateService.new('Services', tenant_name, service_data_file).import
        Importer::Import.new('Agency', general_data_file).agencies
        Importer::Import.new('Department', general_data_file).departments
        # Importer::Import.new('Province', general_data_file).provinces

        # Rake::Task['communes_and_villages:import'].invoke
        # Rake::Task['communes_and_villages:import'].reenable
        Rake::Task['nepali_provinces:import'].invoke
        Importer::Import.new('Quantitative Type', general_data_file).quantitative_types
        Importer::Import.new('Quantitative Case', general_data_file).quantitative_cases
        Rake::Task['client_importer:import'].invoke(tenant_name)
        Rake::Task["field_settings:import"].invoke(tenant_name)
      rescue Apartment::TenantExists => e
        puts "Development environment tenant #{tenant_name} already exisits. If you want to delete this tenant then run `rake db:drop && rake db:setup` and run this rake task agin."
      end
    end
  end
