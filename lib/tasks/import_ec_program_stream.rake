namespace :ec_program_stream do
  desc 'Import Emergency Care case to Emergency Care program stream'
  task import: :environment do
    import = EcImport.new
    import.ec_import
  end
end
