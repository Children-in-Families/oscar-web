namespace :import do
  desc 'Import data for use in the local Development environment only!'
  task brc_env_data: :environment do
    tenant_name = 'brc'
    general_data_file = 'lib/devdata/general.xlsx'
    service_data_file = 'lib/devdata/services/service.xlsx'

    Organization.switch_to tenant_name
    Rake::Task['db:seed'].invoke
    ImportStaticService::DateService.new('Services', tenant_name, service_data_file).import
    Importer::Import.new('Agency', general_data_file).agencies
    Importer::Import.new('Department', general_data_file).departments
    Importer::Import.new('Province', general_data_file).provinces
    Importer::Import.new('District', general_data_file).districts
  end
end
