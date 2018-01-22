namespace :fc do
  desc 'Import FC Management'
  task import: :environment do
    import     = FcImport.new

    import.fc_import
  end
end
