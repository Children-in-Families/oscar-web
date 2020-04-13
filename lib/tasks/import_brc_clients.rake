namespace :brc_client do
  desc 'Import clients & family data for IFRC'
  task import: :environment do
    Organization.switch_to 'brc'
    BrcImporter.new.import_all
  end
end
