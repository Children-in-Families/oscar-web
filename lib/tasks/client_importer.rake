namespace :client_importer do
  desc "TODO"
  task :import, [:short_name] => :environment do |task, args|
    short_name = args.short_name
    Organization.switch_to short_name
    import_object = ClientsImporter::Import.new('vendor/data/organizations/colt_clients_2020_05_25.xlsx')
    import_object.import_all
    puts "Done!!!"
  end

end
