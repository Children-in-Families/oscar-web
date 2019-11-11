namespace :import do
    desc 'Import data for use in the local Development environment only!'
    task dev_env_data: :environment do
      exit unless Rails.env.development?
      tenant_name = 'dev'
      begin
        Organization.create_and_build_tanent(full_name: 'Shared', short_name: 'shared')
      rescue Apartment::TenantExists => e
        puts "Shared tenant exists already."
      end
      begin
        Organization.create_and_build_tanent(short_name: tenant_name, full_name: 'Development Environment', logo: File.open(Rails.root.join('app/assets/images/hol logo.jpg')))
        Organization.switch_to tenant_name
        Rake::Task['db:seed'].invoke
        ImportStaticService::DateService.new('Sheet1', 'dev').import
        Rake::Task['agencies:import'].invoke
        Rake::Task['departments:import'].invoke
        Rake::Task['provinces:import'].invoke
        Rake::Task['districts:import'].invoke
        Rake::Task['quantitative_types:import'].invoke
        Rake::Task['quantitative_cases:import'].invoke
        # Rake::Task['communes_and_villages:import'].invoke
        DevEnvImporter::Import.new('Users').users
        DevEnvImporter::Import.new('Family').families
        DevEnvImporter::Import.new('Client').clients
        Rake::Task['client_to_shared:copy'].invoke
      rescue Apartment::TenantExists => e
        puts "Development environment #{tenant_name} exisits already. Nothing done. If you want to delete this tenant then run `drop schema dev CASCADE;` using psql and run this rake task agin."
      end
    end
  end
