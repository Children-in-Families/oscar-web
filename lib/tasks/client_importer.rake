namespace :client_importer do
  desc "TODO"
  task :import, [:short_name] => :environment do |task, args|
    short_name = args.short_name
    Organization.switch_to short_name
    path = Rails.root.join("vendor/data/organizations/client_data_import_nepal.xlsx")
    import_object = NepalDataImporter::Import.new(path)
    import_object.import_all
    puts "Done!!!"
  end

end
