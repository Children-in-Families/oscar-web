namespace :tlc do
  desc 'Import all TLC clients and related data'
  task import: :environment do
    Organization.switch_to 'tlc'

    import     = TlcImporter::Import.new('Client')
    import.clients
  end
end
