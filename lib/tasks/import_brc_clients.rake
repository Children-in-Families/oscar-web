namespace :brc_client do
  desc 'Import clients & family data for IFRC'
  task import: :environment do
    Organization.switch_to 'brc'

    Rake::Task['import:brc_env_data'].invoke
    BrcImporter.new.import_all
  end
end
