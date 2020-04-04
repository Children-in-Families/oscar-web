namespace :client_importer do
  desc "TODO"
  task :import, [:short_name] => :environment do |task, args|
    short_name = args.short_name
    Organization.switch_to short_name
    import_object = ClientsImporter::Import.new('vendor/data/organizations/ratanak_oscar_03_april_2020.xlsx', ['clients'])
    import_object.import_all
    puts "Done!!!"
  end

end
