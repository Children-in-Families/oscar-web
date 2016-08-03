namespace :departments do
  desc 'Import all departments'
  task import: :environment do
    sheet_name = 'Department'
    import     = Importer::Import.new(sheet_name)
    import.departments
  end
end
