namespace :fc do
  desc 'Import Foster Care case to Foster Care program stream'
  task import: :environment do
    import = FcImport.new
    import.fc_import
  end
end
