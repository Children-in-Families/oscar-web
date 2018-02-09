namespace :kc do
  desc 'Import Foster Care case to Foster Care program stream'
  task import: :environment do
    import = KcImport.new
    import.kc_import
  end
end
