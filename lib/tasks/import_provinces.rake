namespace :provinces do
  desc 'Import all provinces'
  task import: :environment do
    Organization.switch_to 'shared'
    sheet_name = 'Province'
    import     = Importer::Import.new(sheet_name)
    import.provinces
  end
end
