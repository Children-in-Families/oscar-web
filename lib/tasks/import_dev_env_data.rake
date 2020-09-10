namespace :import do
    desc 'Import data for use in the local Development environment only!'
    task dev_env_data: :environment do
      exit unless Rails.env.development?
      tenant_name = 'dev'
      general_data_file = 'lib/devdata/general.xlsx'
      service_data_file = 'lib/devdata/services/service.xlsx'
      begin
        Organization.create_and_build_tenant(full_name: 'Shared', short_name: 'shared')
      rescue Apartment::TenantExists => e
        puts "Shared tenant exists already."
      end
      begin
        Organization.create_and_build_tenant(short_name: tenant_name, full_name: 'Development Environment', logo: File.open(Rails.root.join('app/assets/images/dev-tenant-logo.jpg')))
        Organization.switch_to tenant_name
        Rake::Task['db:seed'].invoke
        ImportStaticService::DateService.new('Services', tenant_name, service_data_file).import
        Importer::Import.new('Agency', general_data_file).agencies
        Importer::Import.new('Department', general_data_file).departments
        Importer::Import.new('Province', general_data_file).provinces
        Rake::Task['communes_and_villages:import'].invoke
        Importer::Import.new('Quantitative Type', general_data_file).quantitative_types
        Importer::Import.new('Quantitative Case', general_data_file).quantitative_cases
        DevEnvImporter::Import.new.import_all
        Rake::Task['client_to_shared:copy'].invoke
      rescue Apartment::TenantExists => e
        puts "Development environment tenant #{tenant_name} already exisits. If you want to delete this tenant then run `rake db:drop && rake db:setup` and run this rake task agin."
      end
    end
  end
