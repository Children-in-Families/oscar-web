namespace :import_garden_of_home do
    desc 'Import data for garden of hope.'
    task import: :environment do
      # exit unless Rails.env.development?
      tenant_name = 'goh'
      general_data_file = 'lib/devdata/general.xlsx'
      service_data_file = 'lib/devdata/services/service.xlsx'
      begin
        begin
          Organization.create_and_build_tenant(short_name: tenant_name, full_name: 'Garden Of Hope', logo: File.open(Rails.root.join('app/assets/images/Logo_GOHC.png')))
        rescue Apartment::TenantExists => e
          puts "Garden Of Hope tenant exists already."
        end
        Organization.switch_to tenant_name
        # Rake::Task['db:seed'].invoke
        # ImportStaticService::DateService.new('Services', tenant_name, service_data_file).import
        # Importer::Import.new('Agency', general_data_file).agencies
        # Importer::Import.new('Department', general_data_file).departments
        # Importer::Import.new('Province', general_data_file).provinces
        # Rake::Task['communes_and_villages:import'].invoke(tenant_name)
        # Importer::Import.new('Quantitative Type', general_data_file).quantitative_types
        # Importer::Import.new('Quantitative Case', general_data_file).quantitative_cases
        GardenOfHomeImporter::Import.new('vendor/data/organizations/Client-Data-Import_Garden_of_Hope.xlsx', ['clients']).import_all
        Rake::Task['client_to_shared:copy'].invoke(tenant_name)
        Rake::Task["field_settings:import"].invoke(tenant_name)
      rescue Apartment::TenantExists => e
        puts "Development environment tenant #{tenant_name} already exisits. If you want to delete this tenant then run `rake db:drop && rake db:setup` and run this rake task agin."
      end
    end
  end
